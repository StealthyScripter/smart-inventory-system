require "rails_helper"

RSpec.describe "Payments", type: :request do
  let!(:category) { Category.create!(name: "Payment Hardware") }
  let!(:supplier) { Supplier.create!(name: "Payment Merchant", default_lead_time_days: 7) }
  let!(:customer) { create_authenticated_user(role: "customer", email: "payment.customer@example.com") }
  let!(:product) do
    Product.create!(
      name: "Payment Bolt",
      sku: "PAY-BOLT",
      category: category,
      supplier: supplier,
      selling_price: 8.00,
      marketplace_status: "public"
    )
  end
  let!(:order) do
    Order.create!(user: customer, status: "pending", total_amount: 8.00).tap do |record|
      record.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 8.00, total_amount: 8.00)
    end
  end

  it "creates a payment record for an order" do
    login_as(customer)

    expect do
      post payments_path, params: { order_id: order.id }
    end.to change(Payment, :count).by(1)

    payment = order.payments.last
    expect(payment.status).to eq("pending")
    expect(payment.provider).to eq("manual")
  end

  it "selects a configured provider when requested" do
    login_as(customer)

    with_env("STRIPE_SECRET_KEY", "sk_test_fake") do
      post payments_path, params: { order_id: order.id, provider: "stripe" }
    end

    payment = order.payments.last
    expect(payment.provider).to eq("stripe")
    expect(payment.provider_reference).to start_with("stripe_pending_")
  end

  it "fails safely when provider credentials are missing" do
    login_as(customer)

    expect do
      without_env("STRIPE_SECRET_KEY") do
        post payments_path, params: { order_id: order.id, provider: "stripe" }
      end
    end.not_to change(Payment, :count)

    expect(response).to redirect_to(checkout_path(order_id: order.id))
    expect(order.reload.status).to eq("pending")
  end

  it "does not allow another customer to create payment for the order" do
    other_customer = create_authenticated_user(role: "customer", email: "other.payment@example.com")
    login_as(other_customer)

    post payments_path, params: { order_id: order.id }

    expect(response).to have_http_status(:not_found)
  end

  it "processes valid simulated paid webhooks" do
    payment = PaymentService.new(order).create_payment!
    payload = {
      id: "evt_paid_1",
      type: "payment.paid",
      payment_reference: payment.provider_reference
    }.to_json
    secret = "test-webhook-secret"
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)

    with_webhook_secret(secret) do
      post webhooks_payments_manual_path, params: payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Manual-Signature" => signature
      }
    end

    expect(response).to have_http_status(:ok)
    expect(payment.reload.status).to eq("paid")
    expect(order.reload.status).to eq("confirmed")
    expect(WebhookEvent.last.status).to eq("processed")
  end

  it "ignores duplicate provider webhooks idempotently" do
    payment = PaymentService.new(order).create_payment!
    payload = {
      id: "evt_duplicate_1",
      type: "payment.paid",
      payment_reference: payment.provider_reference
    }.to_json
    secret = "test-webhook-secret"
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)

    with_webhook_secret(secret) do
      2.times do
        post webhooks_payments_manual_path, params: payload, headers: {
          "CONTENT_TYPE" => "application/json",
          "X-Manual-Signature" => signature
        }
      end
    end

    expect(response).to have_http_status(:ok)
    expect(WebhookEvent.where(external_id: "evt_duplicate_1").count).to eq(1)
    expect(payment.reload.status).to eq("paid")
  end

  it "processes valid simulated Stripe webhooks without live credentials" do
    payment = nil
    with_env("STRIPE_SECRET_KEY", "sk_test_fake") do
      payment = PaymentService.new(order).create_payment!(provider: "stripe")
    end
    payload = {
      id: "evt_stripe_paid_1",
      type: "payment.paid",
      payment_reference: payment.provider_reference
    }.to_json
    secret = "stripe-webhook-secret"
    signature = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)

    with_env("STRIPE_WEBHOOK_SECRET", secret) do
      post webhooks_provider_payment_path(provider: "stripe"), params: payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Stripe-Signature" => signature
      }
    end

    expect(response).to have_http_status(:ok)
    expect(payment.reload.status).to eq("paid")
    expect(order.reload.status).to eq("confirmed")
  end

  it "rejects invalid Stripe webhook signatures" do
    payment = nil
    with_env("STRIPE_SECRET_KEY", "sk_test_fake") do
      payment = PaymentService.new(order).create_payment!(provider: "stripe")
    end
    payload = {
      id: "evt_stripe_bad_1",
      type: "payment.paid",
      payment_reference: payment.provider_reference
    }.to_json

    with_env("STRIPE_WEBHOOK_SECRET", "stripe-webhook-secret") do
      post webhooks_provider_payment_path(provider: "stripe"), params: payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Stripe-Signature" => "bad"
      }
    end

    expect(response).to have_http_status(:unauthorized)
    expect(payment.reload.status).to eq("pending")
    expect(order.reload.status).to eq("pending")
  end

  it "rejects invalid simulated webhook signatures" do
    payment = PaymentService.new(order).create_payment!
    payload = {
      id: "evt_bad_1",
      type: "payment.paid",
      payment_reference: payment.provider_reference
    }.to_json

    with_webhook_secret("test-webhook-secret") do
      post webhooks_payments_manual_path, params: payload, headers: {
        "CONTENT_TYPE" => "application/json",
        "X-Manual-Signature" => "bad"
      }
    end

    expect(response).to have_http_status(:unauthorized)
    expect(payment.reload.status).to eq("pending")
  end

  def with_webhook_secret(secret)
    with_env("MANUAL_PAYMENT_WEBHOOK_SECRET", secret) { yield }
  end

  def with_env(key, value)
    previous = ENV.fetch(key, nil)
    ENV[key] = value
    yield
  ensure
    previous ? ENV[key] = previous : ENV.delete(key)
  end

  def without_env(key)
    previous = ENV.fetch(key, nil)
    ENV.delete(key)
    yield
  ensure
    previous ? ENV[key] = previous : ENV.delete(key)
  end
end

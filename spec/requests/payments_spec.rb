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
    previous = ENV.fetch("MANUAL_PAYMENT_WEBHOOK_SECRET", nil)
    ENV["MANUAL_PAYMENT_WEBHOOK_SECRET"] = secret
    yield
  ensure
    if previous
      ENV["MANUAL_PAYMENT_WEBHOOK_SECRET"] = previous
    else
      ENV.delete("MANUAL_PAYMENT_WEBHOOK_SECRET")
    end
  end
end

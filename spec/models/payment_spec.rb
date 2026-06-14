require "rails_helper"

RSpec.describe Payment, type: :model do
  let(:customer) do
    User.create!(
      first_name: "Payment",
      last_name: "User",
      email: "payment.model@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let(:order) { Order.create!(user: customer, total_amount: 12.00) }

  it "tracks safe payment status transitions through the service" do
    payment = PaymentService.new(order).create_payment!

    PaymentService.new(order).mark_paid!(payment)

    expect(payment.reload.status).to eq("paid")
    expect(order.reload.status).to eq("confirmed")
  end

  it "prevents paying already failed payments" do
    payment = PaymentService.new(order).create_payment!
    PaymentService.new(order).mark_failed!(payment)

    expect do
      PaymentService.new(order).mark_paid!(payment)
    end.to raise_error(ArgumentError)
  end

  it "uses an environment variable for webhook signature verification" do
    payload = { id: "evt", type: "payment.paid", payment_reference: "ref" }.to_json
    signature = OpenSSL::HMAC.hexdigest("SHA256", "secret", payload)

    expect(PaymentWebhookService.valid_signature?(payload, signature)).to be(false)

    previous = ENV.fetch("MANUAL_PAYMENT_WEBHOOK_SECRET", nil)
    ENV["MANUAL_PAYMENT_WEBHOOK_SECRET"] = "secret"
    begin
      expect(PaymentWebhookService.valid_signature?(payload, signature)).to be(true)
    ensure
      if previous
        ENV["MANUAL_PAYMENT_WEBHOOK_SECRET"] = previous
      else
        ENV.delete("MANUAL_PAYMENT_WEBHOOK_SECRET")
      end
    end
  end
end

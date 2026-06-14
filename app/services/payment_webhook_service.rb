class PaymentWebhookService
  SECRET_ENV_KEY = "MANUAL_PAYMENT_WEBHOOK_SECRET".freeze

  def self.valid_signature?(payload, signature)
    secret = ENV.fetch(SECRET_ENV_KEY, nil)
    return false if secret.blank? || signature.blank?

    expected = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end

  def initialize(payload)
    @payload = payload
    @data = JSON.parse(payload)
  end

  def process!
    event = WebhookEvent.find_or_create_by!(provider: "manual", external_id: data.fetch("id")) do |record|
      record.event_type = data.fetch("type")
      record.payload = payload
    end
    return event if event.status == "processed"

    payment = Payment.find_by!(provider_reference: data.fetch("payment_reference"))

    case event.event_type
    when "payment.paid"
      PaymentService.new(payment.order).mark_paid!(payment)
    when "payment.failed"
      PaymentService.new(payment.order).mark_failed!(payment)
    else
      event.update!(status: "rejected")
      return event
    end

    event.update!(status: "processed")
    event
  end

  private

  attr_reader :payload, :data
end

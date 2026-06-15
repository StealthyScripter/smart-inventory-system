class PaymentWebhookService
  def self.valid_signature?(payload, signature, provider: "manual")
    PaymentProviders::Registry.fetch(provider).new.valid_signature?(payload, signature)
  end

  def initialize(payload, provider: "manual")
    @payload = payload
    @provider = provider
    @data = JSON.parse(payload)
  end

  def process!
    event = WebhookEvent.find_or_create_by!(provider: provider, external_id: data.fetch("id")) do |record|
      record.event_type = data.fetch("type")
      record.payload = payload
    end
    return event if event.status == "processed"

    payment = Payment.find_by!(provider_reference: data.fetch("payment_reference"))
    raise ArgumentError, "payment provider mismatch" unless payment.provider == provider

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

  attr_reader :payload, :provider, :data
end

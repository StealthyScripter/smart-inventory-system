module PaymentProviders
  class ManualProvider
    PROVIDER = "manual".freeze
    SIGNATURE_KEY_ENV = "MANUAL_PAYMENT_WEBHOOK_SECRET".freeze

    def create_payment!(order)
      order.payments.create!(
        provider: PROVIDER,
        provider_reference: "manual_#{SecureRandom.hex(8)}",
        amount: order.total_amount,
        currency: "USD",
        status: "pending"
      )
    end

    def valid_signature?(payload, signature)
      secret = ENV.fetch(SIGNATURE_KEY_ENV, nil)
      return false if secret.blank? || signature.blank?

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
      ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    end
  end
end

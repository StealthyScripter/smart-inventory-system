module PaymentProviders
  class StripeProvider
    PROVIDER = "stripe".freeze
    SECRET_KEY_ENV = "STRIPE_SECRET_KEY".freeze
    WEBHOOK_SECRET_ENV = "STRIPE_WEBHOOK_SECRET".freeze

    def create_payment!(order)
      secret_key = ENV.fetch(SECRET_KEY_ENV, nil)
      raise ConfigurationError, "Stripe secret key is not configured" if secret_key.blank?

      order.payments.create!(
        provider: PROVIDER,
        provider_reference: "stripe_pending_#{SecureRandom.hex(8)}",
        amount: order.total_amount,
        currency: "USD",
        status: "pending"
      )
    end

    def valid_signature?(payload, signature)
      secret = ENV.fetch(WEBHOOK_SECRET_ENV, nil)
      return false if secret.blank? || signature.blank?

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
      ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    end
  end
end

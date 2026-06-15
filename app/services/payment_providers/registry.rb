module PaymentProviders
  class Registry
    PROVIDERS = {
      "manual" => ManualProvider,
      "stripe" => StripeProvider
    }.freeze

    def self.fetch(provider)
      PROVIDERS.fetch(provider.to_s)
    rescue KeyError
      raise ConfigurationError, "Unsupported payment provider"
    end
  end
end

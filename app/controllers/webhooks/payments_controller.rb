module Webhooks
  class PaymentsController < ActionController::API
    def create
      payload = request.raw_post
      provider = params[:provider].presence || "manual"
      signature = request.headers["X-#{provider.titleize.delete(' ')}-Signature"]
      unless PaymentWebhookService.valid_signature?(payload, signature, provider: provider)
        head :unauthorized
        return
      end

      PaymentWebhookService.new(payload, provider: provider).process!
      head :ok
    rescue JSON::ParserError, KeyError, ActiveRecord::RecordNotFound, ArgumentError, PaymentProviders::ConfigurationError
      head :unprocessable_content
    end
  end
end

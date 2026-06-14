module Webhooks
  class PaymentsController < ActionController::API
    def create
      payload = request.raw_post
      unless PaymentWebhookService.valid_signature?(payload, request.headers["X-Manual-Signature"])
        head :unauthorized
        return
      end

      PaymentWebhookService.new(payload).process!
      head :ok
    rescue JSON::ParserError, KeyError, ActiveRecord::RecordNotFound, ArgumentError
      head :unprocessable_content
    end
  end
end

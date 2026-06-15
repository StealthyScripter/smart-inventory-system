class PaymentsController < ApplicationController
  before_action :require_customer_access

  def create
    order = current_user.orders.find(params[:order_id])
    payment = PaymentService.new(order).create_payment!(provider: payment_provider)

    redirect_to checkout_path(order_id: order.id, payment_id: payment.id), notice: "Payment was started."
  rescue PaymentProviders::ConfigurationError
    redirect_to checkout_path(order_id: params[:order_id]), alert: "Payment provider is not available."
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to pay."
  end

  def payment_provider
    provider = params[:provider].presence || "manual"
    return provider if Payment::PROVIDERS.include?(provider)

    "manual"
  end
end

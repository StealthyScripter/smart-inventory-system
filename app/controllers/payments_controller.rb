class PaymentsController < ApplicationController
  before_action :require_customer_access

  def create
    order = current_user.orders.find(params[:order_id])
    payment = PaymentService.new(order).create_payment!

    redirect_to checkout_path(order_id: order.id, payment_id: payment.id), notice: "Payment was started."
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to pay."
  end
end

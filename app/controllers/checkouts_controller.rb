class CheckoutsController < ApplicationController
  before_action :require_customer_access

  def show
    @cart = current_cart
  end

  def create
    @order = CheckoutService.new(current_cart).create_order!
    redirect_to checkout_path(order_id: @order.id), notice: "Draft order was created."
  rescue ActiveRecord::RecordInvalid
    redirect_to cart_path, alert: "Your cart could not be checked out."
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to check out."
  end

  def current_cart
    @current_cart ||= Cart.find_or_create_by!(user: current_user, status: "active")
  end
end

class CartsController < ApplicationController
  before_action :require_customer_access

  def show
    @cart = current_cart
  end

  def create
    product = Product.publicly_listed.find(params[:product_id])
    item = current_cart.cart_items.find_or_initialize_by(product: product)
    item.quantity = item.persisted? ? item.quantity + requested_quantity : requested_quantity
    item.save!

    redirect_to cart_path, notice: "Product was added to your cart."
  rescue ActiveRecord::RecordNotFound
    redirect_to catalog_path, alert: "Product is not available."
  rescue ActiveRecord::RecordInvalid
    redirect_to catalog_product_path(params[:product_id]), alert: "Product could not be added to your cart."
  end

  def update
    item = current_cart.cart_items.find(params[:item_id])
    item.update!(quantity: requested_quantity)

    redirect_to cart_path, notice: "Cart was updated."
  rescue ActiveRecord::RecordInvalid
    redirect_to cart_path, alert: "Quantity must be greater than zero."
  end

  def destroy
    current_cart.cart_items.find(params[:item_id]).destroy!
    redirect_to cart_path, notice: "Item was removed from your cart."
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to use the cart."
  end

  def current_cart
    @current_cart ||= Cart.find_or_create_by!(user: current_user, status: "active") do |cart|
      cart.customer_account = current_customer_account
    end
  end

  def requested_quantity
    [params[:quantity].to_i, 1].max
  end
end

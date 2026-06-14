class ReviewsController < ApplicationController
  before_action :require_customer_access

  def create
    order_item = current_user.orders.joins(:order_items).merge(OrderItem.where(id: params[:order_item_id])).first&.order_items&.find(params[:order_item_id])
    review = Review.new(review_params.merge(
      user: current_user,
      order_item: order_item,
      product: order_item&.product,
      supplier: order_item&.supplier
    ))

    if review.save
      redirect_to customer_order_path(order_item.order), notice: "Review was submitted."
    else
      redirect_to customer_order_path(order_item&.order || params[:order_id]), alert: review.errors.full_messages.to_sentence
    end
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to review products."
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end

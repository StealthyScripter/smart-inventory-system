module Customer
  class AnalyticsController < BaseController
    def index
      @orders = current_user.orders
      @purchase_total = @orders.sum(:total_amount)
      @order_count = @orders.count
      @review_count = current_user.reviews.count
    end
  end
end

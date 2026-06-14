module Merchant
  class AnalyticsController < BaseController
    def index
      @order_items = OrderItem.where(supplier: merchant_suppliers)
      @sales_total = @order_items.sum(:total_amount)
      @delivered_count = @order_items.where(fulfillment_status: "delivered").count
      @average_rating = Review.published.where(supplier: merchant_suppliers).average(:rating).to_f
    end
  end
end

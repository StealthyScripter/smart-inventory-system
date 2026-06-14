module Merchant
  class DashboardController < BaseController
    def index
      @products = merchant_products.includes(:stock_levels)
      @product_count = @products.count
      @public_product_count = @products.publicly_listed.count
      @non_public_product_count = @products.where(marketplace_status: ["draft", "private"]).count
      @service_count = ServiceListing.where(supplier: merchant_suppliers).count
      @public_service_count = ServiceListing.where(supplier: merchant_suppliers).publicly_listed.count
      @low_stock_products = low_stock_products
      @sales_summary = AnalyticsSummary.for_merchant(merchant_suppliers)
      @pending_orders_count = OrderItem.where(supplier: merchant_suppliers).where.not(fulfillment_status: ["delivered", "cancelled"]).count
      @booking_queue = ServiceBooking.where(supplier: merchant_suppliers, status: ["requested", "accepted"]).order(:created_at).limit(5)
      @upcoming_jobs = ServiceBooking.where(supplier: merchant_suppliers, status: ["scheduled", "in_progress"])
                                    .where("scheduled_date >= ?", Date.current)
                                    .order(:scheduled_date, :scheduled_time)
                                    .limit(5)
    end

    private

    def low_stock_products
      @products.select { |product| product.total_stock < product.reorder_point }
               .sort_by(&:total_stock)
               .first(5)
    end
  end
end

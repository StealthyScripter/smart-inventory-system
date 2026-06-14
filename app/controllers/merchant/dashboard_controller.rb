module Merchant
  class DashboardController < BaseController
    def index
      @products = merchant_products.includes(:stock_levels)
      @product_count = @products.count
      @public_product_count = @products.publicly_listed.count
      @non_public_product_count = @products.where(marketplace_status: ["draft", "private"]).count
      @low_stock_products = low_stock_products
      @pending_orders_count = merchant_orders.where(status: "pending").count
    end

    private

    def low_stock_products
      @products.select { |product| product.total_stock < product.reorder_point }
               .sort_by(&:total_stock)
               .first(5)
    end

    def merchant_orders
      PurchaseOrder.where(supplier: merchant_suppliers)
    end
  end
end

class DashboardController < ApplicationController
  def index
    @total_products = Product.count
    @total_value = calculate_total_inventory_value
    @low_stock_products = find_low_stock_products
    @recent_sales = SalesTransaction.recent.includes(:product, :location).limit(10)
    @pending_orders = PurchaseOrder.pending.count
    @out_of_stock_count = count_out_of_stock_products
  end

  private

  def calculate_total_inventory_value
    StockLevel.joins(:product)
              .sum("stock_levels.current_quantity * products.unit_cost")
              .to_f
  end

  def find_low_stock_products
    # Get all products and filter in Ruby
    Product.includes(:stock_levels).all.select do |product|
      product.total_stock < product.reorder_point
    end.sort_by(&:total_stock).take(5)
  end

  def count_out_of_stock_products
    Product.includes(:stock_levels).all.count do |product|
      product.total_stock == 0
    end
  end
end

class DashboardController < ApplicationController
  def index
    @total_products = Product.count
    @total_value = calculate_total_inventory_value
    @low_stock_items = find_low_stock_products.limit(5)
    @recent_sales = SalesTransaction.recent.includes(:product, :location).limit(10)
    @pending_orders = PurchaseOrder.pending.count
    @out_of_stock_count = Product.joins(:stock_levels).where(stock_levels: { current_quantity: 0 }).distinct.count
  end

  private

  def calculate_total_inventory_value
    StockLevel.joins(:product)
              .sum("stock_levels.current_quantity * products.unit_cost")
              .to_f
  end

  def find_low_stock_products
    Product.joins(:stock_levels)
           .where("stock_levels.current_quantity < products.reorder_point")
           .includes(:stock_levels)
  end
end

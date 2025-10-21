class DashboardController < ApplicationController
  def index
    @total_products = Product.count
    @total_value = calculate_total_inventory_value
    @low_stock_products = find_low_stock_products
    @recent_sales = scoped_recent_sales
    @pending_orders = scoped_pending_orders
    @out_of_stock_count = count_out_of_stock_products
  end

  private

  def calculate_total_inventory_value
    if admin? || manager?
      # Admin and manager see total across all locations
      StockLevel.joins(:product)
                .sum("stock_levels.current_quantity * products.unit_cost")
                .to_f
    elsif supervisor? || employee?
      # Supervisor and employee only see their location's value
      StockLevel.joins(:product)
                .where(location: current_user.location)
                .sum("stock_levels.current_quantity * products.unit_cost")
                .to_f
    else
      # Guests see overall value
      StockLevel.joins(:product)
                .sum("stock_levels.current_quantity * products.unit_cost")
                .to_f
    end
  end

  def find_low_stock_products
    products = Product.includes(:stock_levels).all

    if admin? || manager?
      # Show low stock across all locations
      products.select { |product| product.total_stock < product.reorder_point }
              .sort_by(&:total_stock)
              .take(5)
    elsif supervisor? || employee?
      # Show low stock only in their location
      products.select do |product|
        location_stock = product.stock_levels.find_by(location: current_user.location)
        location_stock && location_stock.current_quantity < product.reorder_point
      end.sort_by do |product|
        product.stock_levels.find_by(location: current_user.location)&.current_quantity || 0
      end.take(5)
    else
      # Guests see overall low stock
      products.select { |product| product.total_stock < product.reorder_point }
              .sort_by(&:total_stock)
              .take(5)
    end
  end

  def scoped_recent_sales
    if admin? || manager?
      # Show all recent sales
      SalesTransaction.recent.includes(:product, :location, :user).limit(10)
    elsif supervisor? || employee?
      # Show only sales from their location
      SalesTransaction.recent
                      .includes(:product, :location, :user)
                      .where(location: current_user.location)
                      .limit(10)
    else
      # Guests cannot see sales
      SalesTransaction.none
    end
  end

  def scoped_pending_orders
    if admin? || manager? || supervisor?
      # Can see purchase orders
      PurchaseOrder.pending.count
    else
      # Employees and guests cannot see purchase orders
      0
    end
  end

  def count_out_of_stock_products
    if admin? || manager?
      # Count out of stock across all locations
      Product.includes(:stock_levels).all.count { |product| product.total_stock == 0 }
    elsif supervisor? || employee?
      # Count out of stock in their location only
      Product.includes(:stock_levels).all.count do |product|
        location_stock = product.stock_levels.find_by(location: current_user.location)
        location_stock && location_stock.current_quantity == 0
      end
    else
      # Guests see overall out of stock
      Product.includes(:stock_levels).all.count { |product| product.total_stock == 0 }
    end
  end
end

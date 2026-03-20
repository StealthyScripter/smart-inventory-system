class DashboardController < ApplicationController
  def index
    @total_products = Product.count
    @total_locations = Location.count
    @inventory_units = scoped_stock_levels.sum(:current_quantity)
    @total_value = calculate_total_inventory_value
    @low_stock_products = find_low_stock_products
    @recent_movements = scoped_recent_movements.limit(8)
  end

  private

  def scoped_stock_levels
    relation = StockLevel.joins(:product).includes(:product, :location)

    return relation if admin? || regional_manager?
    return relation.where(location_id: current_user.location_id) if current_user&.location_id && (location_manager? || department_manager? || employee?)

    relation
  end

  def calculate_total_inventory_value
    scoped_stock_levels.sum("stock_levels.current_quantity * COALESCE(products.unit_cost, 0)").to_f
  end

  def find_low_stock_products
    products = Product.includes(:stock_levels).order(:name)

    if current_user&.location_id && (location_manager? || department_manager? || employee?)
      products.filter_map do |product|
        stock_level = product.stock_levels.find { |level| level.location_id == current_user.location_id }
        product if stock_level && stock_level.current_quantity < product.reorder_point
      end.sort_by do |product|
        product.stock_levels.find { |level| level.location_id == current_user.location_id }&.current_quantity || 0
      end.first(5)
    else
      products.select { |product| product.total_stock < product.reorder_point }
              .sort_by(&:total_stock)
              .first(5)
    end
  end

  def scoped_recent_movements
    relation = StockMovement.includes(:product, :destination_location, :source_location, :user)
                            .order(movement_date: :desc)

    if current_user&.location_id && (location_manager? || department_manager? || employee?)
      relation.where("source_location_id = :location_id OR destination_location_id = :location_id", location_id: current_user.location_id)
    elsif client? || supplier_user? || customer? || guest?
      StockMovement.none
    else
      relation
    end
  end
end

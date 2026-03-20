class InventoryController < ApplicationController
  before_action :require_inventory_adjustment_permission, only: [:adjust_stock]

  def index
    @stock_levels = scoped_stock_levels
    @locations = viewable_locations
  end

  def adjust_stock
    product = Product.find(params[:product_id])
    location = Location.find(params[:location_id])

    unless can_access_location?(location)
      redirect_to inventory_path, alert: "You can only adjust stock in your assigned location."
      return
    end

    stock_level = StockLevel.find_or_initialize_by(product: product, location: location)
    old_quantity = stock_level.current_quantity.to_i
    new_quantity = params[:quantity].to_i

    if new_quantity == old_quantity
      redirect_to inventory_path, notice: "Stock level was already up to date."
      return
    end

    StockLevel.transaction do
      stock_level.update!(current_quantity: new_quantity)
      StockMovement.create!(
        product: product,
        destination_location: location,
        movement_type: "adjustment",
        quantity: (new_quantity - old_quantity).abs,
        user: current_user,
        movement_date: Time.current,
        notes: "Stock adjusted from #{old_quantity} to #{new_quantity}"
      )
    end

    redirect_to inventory_path, notice: "Stock level updated successfully."
  rescue ActiveRecord::RecordInvalid
    redirect_to inventory_path, alert: "Failed to update stock level."
  end

  private

  def scoped_stock_levels
    StockLevel.joins(:product, :location)
              .includes(:product, :location)
              .order("products.name ASC, locations.name ASC")
  end
end

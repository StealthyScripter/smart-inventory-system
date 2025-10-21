class InventoryController < ApplicationController
  def index
    @stock_levels = scoped_stock_levels
    @locations = viewable_locations
  end

  def adjust_stock
    # Only admin, manager, and supervisor can adjust stock
    unless can_edit?
      redirect_to inventory_path, alert: "You don't have permission to adjust stock."
      return
    end

    product = Product.find(params[:product_id])
    location = Location.find(params[:location_id])

    # Check location access for supervisors
    if supervisor? && location != current_user.location
      redirect_to inventory_path, alert: "You can only adjust stock in your assigned location."
      return
    end

    stock_level = StockLevel.find_or_initialize_by(product: product, location: location)
    old_quantity = stock_level.current_quantity
    new_quantity = params[:quantity].to_i

    if stock_level.update(current_quantity: new_quantity)
      # Create stock movement record
      StockMovement.create!(
        product: product,
        destination_location: location,
        movement_type: "adjustment",
        quantity: (new_quantity - old_quantity).abs,
        user: current_user,
        movement_date: Time.current,
        notes: "Stock adjusted from #{old_quantity} to #{new_quantity}"
      )

      redirect_to inventory_path, notice: "Stock level updated successfully."
    else
      redirect_to inventory_path, alert: "Failed to update stock level."
    end
  end

  private

  def scoped_stock_levels
    if admin? || manager?
      # Show all stock levels across all locations
      StockLevel.includes(:product, :location).order("products.name")
    elsif supervisor? || employee?
      # Show all stock levels but highlight their location
      # They can VIEW all locations but can only OPERATE in their own
      StockLevel.includes(:product, :location).order("products.name")
    else
      # Guests can view all stock levels (read-only)
      StockLevel.includes(:product, :location).order("products.name")
    end
  end

  def viewable_locations
    # All users can view all locations (for inventory visibility)
    # But supervisors and employees can only operate in their own
    Location.all.order(:name)
  end
end

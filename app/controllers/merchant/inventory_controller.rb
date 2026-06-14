module Merchant
  class InventoryController < BaseController
    def index
      @stock_levels = merchant_stock_levels
    end

    def update
      stock_level = merchant_stock_levels.find(params[:id])
      quantity = inventory_params[:current_quantity].to_i
      previous_quantity = stock_level.current_quantity

      StockLevel.transaction do
        stock_level.update!(current_quantity: quantity)
        StockMovement.create!(
          product: stock_level.product,
          destination_location: stock_level.location,
          movement_type: "adjustment",
          quantity: (quantity - previous_quantity).abs,
          user: current_user,
          movement_date: Time.current,
          notes: "Merchant inventory adjustment"
        ) if quantity != previous_quantity
      end

      redirect_to merchant_inventory_path, notice: "Inventory was updated."
    rescue ActiveRecord::RecordInvalid
      redirect_to merchant_inventory_path, alert: "Inventory could not be updated."
    end

    private

    def inventory_params
      params.require(:stock_level).permit(:current_quantity)
    end
  end
end

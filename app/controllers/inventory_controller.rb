class InventoryController < ApplicationController
  def index
    @stock_levels = StockLevel.includes(:product, :location).order("products.name")
    @locations = Location.all.order(:name)
  end
end

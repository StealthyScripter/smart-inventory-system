def index
  @stock_levels = StockLevel.includes(:product, :location)
  @locations = Location.all
end

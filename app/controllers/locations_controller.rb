def index
  @locations = Location.includes(:manager, :stock_levels)
end

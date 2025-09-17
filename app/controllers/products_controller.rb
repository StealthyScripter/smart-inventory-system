def index
  @products = Product.includes(:category, :supplier, :stock_levels)
end

def index
    @recent_transactions = SalesTransaction.today
    .includes(:product, :location, :user)
    @products = Product.includes(:stock_levels)
    @locations = Location.all
end
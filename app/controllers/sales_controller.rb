class SalesController < ApplicationController
  def index
    @recent_transactions = SalesTransaction.includes(:product, :location, :user)
                                          .where("transaction_date >= ?", Date.current)
                                          .order(transaction_date: :desc)
    @products = Product.includes(:stock_levels)
    @locations = Location.all.order(:name)
  end
end

# app/controllers/forecasting_controller.rb
class ForecastingController < ApplicationController
  def index
    @forecasts = DemandForecast.includes(:product, :location)
                               .where("forecast_date >= ?", Date.current)
                               .order(:forecast_date)
  end
end

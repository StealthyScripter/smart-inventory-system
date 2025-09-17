class ForecastingController < ApplicationController
  def index
    @forecasts = DemandForecast.includes(:product, :location)
          .where("forecast_date >= ?", Date.current)
          .order(:forecast_date)
  end
end

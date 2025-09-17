def index
  @forecasts = DemandForecast.includes(:product, :location)
    .where('forecast_date >= ?', Date.current)
end
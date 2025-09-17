require 'rails_helper'

RSpec.describe "Forecasting", type: :request do
  let(:category) { Category.create!(name: "Electronics") }
  let(:location) { Location.create!(name: "Main Store") }
  let(:product) { Product.create!(name: "iPhone", sku: "IP001", category: category, reorder_point: 10, lead_time_days: 7) }
  let!(:demand_forecast) {
    DemandForecast.create!(
      product: product,
      location: location,
      forecast_date: Date.current + 1.week,
      period_type: "weekly",
      predicted_demand: 25.5,
      confidence_score: 0.85
    )
  }

  describe "GET /forecasting" do
    it "returns http success" do
      get forecasting_path
      expect(response).to have_http_status(:success)
    end

    it "displays forecasting content" do
      get forecasting_path
      expect(response.body).to include("Demand Forecasting")
      expect(response.body).to include("Forecast Summary")
    end

    it "shows forecast data" do
      get forecasting_path
      expect(response.body).to include(product.name)
      expect(response.body).to include(location.name)
    end

    it "assigns forecasts" do
      get forecasting_path
      expect(assigns(:forecasts)).to include(demand_forecast)
    end
  end
end

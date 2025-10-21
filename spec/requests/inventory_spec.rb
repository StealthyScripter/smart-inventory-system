require 'rails_helper'

RSpec.describe "Inventory", type: :request do
  let(:user) { create_authenticated_user }
  let(:category) { Category.create!(name: "Electronics") }
  let(:location) { Location.create!(name: "Main Store") }
  let(:product) {
    Product.create!(
      name: "iPhone",
      sku: "IP001",
      category: category,
      reorder_point: 10,
      lead_time_days: 7,
      unit_cost: 799.00,          # Added unit_cost
      selling_price: 999.00        # Added selling_price
    )
  }
  let!(:stock_level) { StockLevel.create!(product: product, location: location, current_quantity: 50) }

  before do
    login_as(user)
  end

  describe "GET /inventory" do
    it "returns http success" do
      get inventory_path
      expect(response).to have_http_status(:success)
    end

    it "displays inventory management content" do
      get inventory_path
      expect(response.body).to include("Inventory Management")
      expect(response.body).to include("Current Stock Levels")
    end

    it "shows stock levels" do
      get inventory_path
      expect(response.body).to include(product.name)
      expect(response.body).to include(location.name)
    end

    it "assigns stock levels and locations" do
      get inventory_path
      expect(assigns(:stock_levels)).to include(stock_level)
      expect(assigns(:locations)).to include(location)
    end
  end
end

require "rails_helper"

RSpec.describe "Locations", type: :request do
  let(:user) { create_authenticated_user(role: "regional_manager") }
  let!(:location) { Location.create!(name: "Main Warehouse", address: "123 Main St") }
  let!(:category) { Category.create!(name: "Electronics") }
  let!(:product) { Product.create!(name: "Barcode Scanner", sku: "BAR001", category: category, reorder_point: 5, lead_time_days: 3) }

  before do
    login_as(user)
  end

  describe "GET /locations" do
    it "returns http success" do
      get locations_path
      expect(response).to have_http_status(:success)
    end

    it "displays locations list" do
      get locations_path
      expect(response.body).to include("Locations")
      expect(response.body).to include(location.name)
    end
  end

  describe "POST /locations" do
    it "backfills stock levels for existing products" do
      expect do
        post locations_path, params: { location: { name: "Downtown", address: "55 Main St" } }
      end.to change(Location, :count).by(1)
        .and change(StockLevel, :count).by(Product.count)

      expect(response).to redirect_to(Location.last)
      expect(StockLevel.find_by(product: product, location: Location.last)).to be_present
    end
  end
end

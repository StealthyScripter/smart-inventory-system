require 'rails_helper'

RSpec.describe "Locations", type: :request do
  let(:user) { create_authenticated_user }
  let!(:location) { Location.create!(name: "Main Warehouse", address: "123 Main St") }

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

  describe "GET /locations/:id" do
    it "returns http success" do
      get location_path(location)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested location" do
      get location_path(location)
      expect(assigns(:location)).to eq(location)
    end
  end
end

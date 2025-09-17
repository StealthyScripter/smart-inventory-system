require 'rails_helper'

RSpec.describe "Suppliers", type: :request do
  let!(:supplier) { Supplier.create!(name: "Apple Inc.", contact_email: "orders@apple.com", default_lead_time_days: 7) }

  describe "GET /suppliers" do
    it "returns http success" do
      get suppliers_path
      expect(response).to have_http_status(:success)
    end

    it "displays suppliers list" do
      get suppliers_path
      expect(response.body).to include("Suppliers")
      expect(response.body).to include(supplier.name)
      expect(response.body).to include(supplier.contact_email)
    end
  end

  describe "GET /suppliers/:id" do
    it "returns http success" do
      get supplier_path(supplier)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested supplier" do
      get supplier_path(supplier)
      expect(assigns(:supplier)).to eq(supplier)
    end
  end
end

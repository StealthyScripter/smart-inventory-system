require 'rails_helper'

RSpec.describe "Purchase Orders", type: :request do
  let(:authenticated_user) { create_authenticated_user }
  let(:supplier) { Supplier.create!(name: "Apple Inc.", default_lead_time_days: 7) }
  # Use the authenticated_user instead of creating a separate user
  let!(:purchase_order) {
    PurchaseOrder.create!(
      supplier: supplier,
      user: authenticated_user,  # Changed from 'user' to 'authenticated_user'
      order_number: "PO-001",
      order_date: Date.current,
      status: "pending"
    )
  }

  before do
    login_as(authenticated_user)
  end

  describe "GET /purchase_orders" do
    it "returns http success" do
      get purchase_orders_path
      expect(response).to have_http_status(:success)
    end

    it "displays purchase orders list" do
      get purchase_orders_path
      expect(response.body).to include("Purchase Orders")
      expect(response.body).to include(purchase_order.order_number)
      expect(response.body).to include(supplier.name)
    end

    it "assigns purchase orders" do
      get purchase_orders_path
      expect(assigns(:purchase_orders)).to include(purchase_order)
    end
  end

  describe "GET /purchase_orders/:id" do
    it "returns http success" do
      get purchase_order_path(purchase_order)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested purchase order" do
      get purchase_order_path(purchase_order)
      expect(assigns(:purchase_order)).to eq(purchase_order)
    end
  end
end

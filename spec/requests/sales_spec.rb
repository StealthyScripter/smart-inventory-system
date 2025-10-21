require 'rails_helper'

RSpec.describe "Sales", type: :request do
  let(:location) { Location.create!(name: "Main Store") }
  # Create authenticated user with manager role and location
  let(:authenticated_user) { create_authenticated_user(role: "manager", location: location) }
  let(:category) { Category.create!(name: "Electronics") }
  let(:product) { Product.create!(name: "iPhone", sku: "IP001", category: category, reorder_point: 10, lead_time_days: 7) }
  let!(:stock_level) { StockLevel.create!(product: product, location: location, current_quantity: 50) }
  let!(:sales_transaction) {
    SalesTransaction.create!(
      product: product,
      location: location,
      user: authenticated_user,  # Use authenticated_user instead of separate user
      quantity: 1,
      unit_price: 999.99,
      total_amount: 999.99,
      transaction_date: Time.current
    )
  }

  before do
    login_as(authenticated_user)
  end

  describe "GET /sales" do
    it "returns http success" do
      get sales_path
      expect(response).to have_http_status(:success)
    end

    it "displays sales content" do
      get sales_path
      expect(response.body).to include("Sales &amp; Transactions")
      expect(response.body).to include("Quick Sale")
      expect(response.body).to include("Today's Sales")
    end

    it "shows recent transactions" do
      get sales_path
      expect(response.body).to include(product.name)
    end

    it "assigns necessary data" do
      get sales_path
      expect(assigns(:recent_transactions)).to include(sales_transaction)
      expect(assigns(:products)).to include(product)
      expect(assigns(:locations)).to include(location)
    end
  end
end

require "rails_helper"

RSpec.describe "Inventory", type: :request do
  let(:location) { Location.create!(name: "Main Store") }
  let(:user) { create_authenticated_user(role: "department_manager", location: location) }
  let(:category) { Category.create!(name: "Electronics") }
  let(:product) do
    Product.create!(
      name: "iPhone",
      sku: "IP001",
      category: category,
      reorder_point: 10,
      lead_time_days: 7,
      unit_cost: 799.00,
      selling_price: 999.00
    )
  end
  let!(:stock_level) do
    StockLevel.find_or_create_by!(product: product, location: location).tap do |record|
      record.update!(current_quantity: 50, reserved_quantity: 0)
    end
  end

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
  end

  describe "POST /inventory/adjust" do
    it "creates an adjustment movement when the quantity changes" do
      expect do
        post inventory_adjust_path, params: { product_id: product.id, location_id: location.id, quantity: 40 }
      end.to change(StockMovement, :count).by(1)

      expect(response).to redirect_to(inventory_path)
      expect(stock_level.reload.current_quantity).to eq(40)
    end

    it "does not create a movement when the quantity is unchanged" do
      expect do
        post inventory_adjust_path, params: { product_id: product.id, location_id: location.id, quantity: 50 }
      end.not_to change(StockMovement, :count)

      expect(response).to redirect_to(inventory_path)
      expect(stock_level.reload.current_quantity).to eq(50)
    end
  end
end

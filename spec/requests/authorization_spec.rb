require "rails_helper"

RSpec.describe "Authorization", type: :request do
  let!(:category) { Category.create!(name: "Electronics") }
  let!(:supplier) { Supplier.create!(name: "Test Supplier", default_lead_time_days: 7) }
  let!(:product) { Product.create!(name: "Test Product", sku: "AUTH-001", category: category, supplier: supplier) }
  let!(:location) { Location.create!(name: "Main Warehouse") }

  describe "back-office access" do
    %w[admin regional_manager location_manager department_manager employee client].each do |role|
      it "allows #{role} to view inventory management screens" do
        user = create_authenticated_user(role: role, location: scoped_location_for(role))

        login_as(user)
        expect(response).to redirect_to(root_path)
        expect(session[:user_id]).to eq(user.id)

        get products_path
        expect(response).to have_http_status(:success)

        get suppliers_path
        expect(response).to have_http_status(:success)

        get locations_path
        expect(response).to have_http_status(:success)

        get inventory_path
        expect(response).to have_http_status(:success)
      end
    end

    %w[supplier customer guest].each do |role|
      it "blocks #{role} from inventory management screens" do
        user = create_authenticated_user(role: role)

        login_as(user)

        get root_path
        expect(response).to have_http_status(:forbidden)

        get products_path
        expect(response).to have_http_status(:forbidden)

        get suppliers_path
        expect(response).to have_http_status(:forbidden)

        get locations_path
        expect(response).to have_http_status(:forbidden)

        get inventory_path
        expect(response).to have_http_status(:forbidden)

        get product_path(product, format: :json)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  private

  def scoped_location_for(role)
    return location if User::LOCATION_SCOPED_ROLES.include?(role)

    nil
  end
end

require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let!(:user) do
    User.create!(
      email: "test@example.com",
      first_name: "Test",
      last_name: "User",
      role: "regional_manager",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe "Login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "logs in the user and redirects to dashboard" do
      post login_path, params: { email: user.email, password: "password123" }

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it "renders an error for invalid credentials" do
      post login_path, params: { email: user.email, password: "wrongpassword" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password")
    end
  end

  describe "Logout" do
    before do
      post login_path, params: { email: user.email, password: "password123" }
    end

    it "clears the session" do
      delete logout_path
      expect(session[:user_id]).to be_nil
    end
  end

  describe "Protected Routes" do
    let(:category) { Category.create!(name: "Electronics") }
    let(:supplier) { Supplier.create!(name: "Test Supplier", default_lead_time_days: 7) }
    let(:product) { Product.create!(name: "Test Product", sku: "TEST001", category: category, reorder_point: 10, lead_time_days: 7, supplier: supplier) }

    context "when not authenticated" do
      it "redirects inventory screens to login" do
        get root_path
        expect(response).to redirect_to(login_path)

        get products_path
        expect(response).to redirect_to(login_path)

        get suppliers_path
        expect(response).to redirect_to(login_path)

        get locations_path
        expect(response).to redirect_to(login_path)

        get inventory_path
        expect(response).to redirect_to(login_path)

        get product_path(product)
        expect(response).to redirect_to(login_path)
      end
    end

    context "when authenticated" do
      before do
        post login_path, params: { email: user.email, password: "password123" }
      end

      it "allows access to the inventory management surface" do
        get root_path
        expect(response).to have_http_status(:success)

        get products_path
        expect(response).to have_http_status(:success)

        get suppliers_path
        expect(response).to have_http_status(:success)

        get inventory_path
        expect(response).to have_http_status(:success)

        get admin_users_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

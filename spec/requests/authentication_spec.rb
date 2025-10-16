require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let!(:user) {
    User.create!(
      email: "test@example.com",
      first_name: "Test",
      last_name: "User",
      role: "staff",
      password: "password123",
      password_confirmation: "password123"
    )
  }

  describe "Login" do
    describe "GET /login" do
      it "returns http success" do
        get login_path
        expect(response).to have_http_status(:success)
      end

      it "displays login form" do
        get login_path
        expect(response.body).to include("Sign in to your account")
      end
    end

    describe "POST /login" do
      context "with valid credentials" do
        it "logs in the user and redirects to dashboard" do
          post login_path, params: { email: user.email, password: "password123" }
          expect(response).to redirect_to(root_path)
          expect(session[:user_id]).to eq(user.id)
        end

        it "sets a success notice" do
          post login_path, params: { email: user.email, password: "password123" }
          follow_redirect!
          expect(response.body).to include("Logged in successfully")
        end
      end

      context "with invalid credentials" do
        it "does not log in the user" do
          post login_path, params: { email: user.email, password: "wrongpassword" }
          expect(session[:user_id]).to be_nil
        end

        it "renders the login form with an error" do
          post login_path, params: { email: user.email, password: "wrongpassword" }
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include("Invalid email or password")
        end
      end

      context "with non-existent user" do
        it "does not log in" do
          post login_path, params: { email: "nonexistent@example.com", password: "password123" }
          expect(session[:user_id]).to be_nil
        end
      end
    end
  end

  describe "Logout" do
    before do
      post login_path, params: { email: user.email, password: "password123" }
    end

    describe "DELETE /logout" do
      it "logs out the user" do
        delete logout_path
        expect(session[:user_id]).to be_nil
      end

      it "redirects to login page" do
        delete logout_path
        expect(response).to redirect_to(login_path)
      end

      it "sets a success notice" do
        delete logout_path
        follow_redirect!
        expect(response.body).to include("Logged out successfully")
      end
    end
  end

  describe "Protected Routes" do
    let(:category) { Category.create!(name: "Electronics") }
    let(:location) { Location.create!(name: "Main Store") }
    let(:supplier) { Supplier.create!(name: "Test Supplier", default_lead_time_days: 7) }
    let(:product) { Product.create!(name: "Test Product", sku: "TEST001", category: category, reorder_point: 10, lead_time_days: 7) }

    context "when not authenticated" do
      it "redirects dashboard to login" do
        get root_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects products index to login" do
        get products_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects products show to login" do
        get product_path(product)
        expect(response).to redirect_to(login_path)
      end

      it "redirects products new to login" do
        get new_product_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects products create to login" do
        post products_path, params: { product: { name: "New Product" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects products edit to login" do
        get edit_product_path(product)
        expect(response).to redirect_to(login_path)
      end

      it "redirects products update to login" do
        patch product_path(product), params: { product: { name: "Updated" } }
        expect(response).to redirect_to(login_path)
      end

      it "redirects products delete to login" do
        delete product_path(product)
        expect(response).to redirect_to(login_path)
      end

      it "redirects suppliers to login" do
        get suppliers_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects locations to login" do
        get locations_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects sales to login" do
        get sales_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects inventory to login" do
        get inventory_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects forecasting to login" do
        get forecasting_path
        expect(response).to redirect_to(login_path)
      end

      it "redirects purchase orders to login" do
        get purchase_orders_path
        expect(response).to redirect_to(login_path)
      end

      it "shows alert message when redirected" do
        get root_path
        follow_redirect!
        expect(response.body).to include("You must be logged in")
      end
    end

    context "when authenticated" do
      before do
        post login_path, params: { email: user.email, password: "password123" }
      end

      it "allows access to dashboard" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to products" do
        get products_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to sales" do
        get sales_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to inventory" do
        get inventory_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end

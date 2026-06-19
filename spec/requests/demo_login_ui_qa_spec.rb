require "rails_helper"

RSpec.describe "Demo login UI QA", type: :request do
  before do
    DemoMarketplaceSeed.call
    User.create!(
      email: "admin@inventory.com",
      first_name: "System",
      last_name: "Admin",
      role: "admin",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  [
    {
      label: "individual merchant",
      path: :merchants_sign_in_path,
      email: "merchant.construction@example.com",
      landing: :merchant_root_path,
      theme: "theme-individual-merchant"
    },
    {
      label: "enterprise owner",
      path: :merchants_sign_in_path,
      email: "merchant.hardware@example.com",
      landing: :merchant_root_path,
      theme: "theme-enterprise-merchant"
    },
    {
      label: "enterprise employee",
      path: :merchants_sign_in_path,
      email: "merchant.hardware.employee@example.com",
      landing: :merchant_root_path,
      theme: "theme-enterprise-merchant"
    },
    {
      label: "customer",
      path: :customers_sign_in_path,
      email: "buyer.contractor@example.com",
      landing: :catalog_path,
      theme: "theme-customer"
    },
    {
      label: "admin",
      path: :login_path,
      email: "admin@inventory.com",
      landing: :root_path,
      theme: "sidebar--admin"
    }
  ].each do |account|
    it "logs in the seeded #{account[:label]} and lands on the expected page" do
      login_path = public_send(account[:path])
      landing_path = public_send(account[:landing])
      login_context = if login_path == merchants_sign_in_path
        "merchant"
      elsif login_path == customers_sign_in_path
        "customer"
      end

      get login_path
      expect(response).to have_http_status(:success)

      post login_path, params: {
        email: account[:email],
        password: "password123",
        login_context: login_context
      }

      expect(response).to redirect_to(landing_path)
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(response.body).to include(account[:theme])
    end
  end
end

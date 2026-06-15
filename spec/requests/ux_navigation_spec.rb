require "rails_helper"

RSpec.describe "UX navigation", type: :request do
  let!(:category) { Category.create!(name: "UX Category") }
  let!(:supplier) { Supplier.create!(name: "UX Supplier", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "ux.merchant@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "ux.customer@example.com") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "renders global marketplace navigation for linked merchants" do
    login_as(merchant)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Search")
    expect(response.body).to include("Catalog")
    expect(response.body).to include("Services")
    expect(response.body).to include("Merchant")
    expect(response.body).to include("Search marketplace")
    expect(response.body).to include("Recent Activity")
    expect(response.body).to include("Analytics")
  end

  it "renders customer booking empty state" do
    login_as(customer)

    get customer_service_bookings_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("No service bookings yet.")
    expect(response.body).to include("Customer / Bookings")
  end

  it "renders buyer-focused navigation for customers" do
    login_as(customer)

    get catalog_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Catalog")
    expect(response.body).to include("Cart")
    expect(response.body).to include("Orders")
    expect(response.body).to include("Bookings")
    expect(response.body).not_to include(">Inventory<")
    expect(response.body).not_to include(">Suppliers<")
  end

  it "serves root as the public catalog for guests" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Marketplace / Catalog")
  end

  it "renders catalog pagination controls when enough rows exist" do
    25.times do |index|
      Product.create!(
        name: "UX Product #{index}",
        sku: "UX-PRODUCT-#{index}",
        category: category,
        supplier: supplier,
        marketplace_status: "public"
      )
    end

    get catalog_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Page 1")
    expect(response.body).to include("Next")
    expect(response.body).to include("Marketplace / Catalog")
  end
end

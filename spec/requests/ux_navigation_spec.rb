require "rails_helper"

RSpec.describe "UX navigation", type: :request do
  let!(:category) { Category.create!(name: "UX Category") }
  let!(:supplier) { Supplier.create!(name: "UX Supplier", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "ux.merchant@example.com") }
  let!(:customer_user) { create_authenticated_user(role: "customer", email: "ux.customer@example.com") }
  let!(:merchant_account_owner) { create_authenticated_user(role: "customer", email: "ux.account.owner@example.com") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant_user)
  end

  def body_doc
    Nokogiri::HTML(response.body)
  end

  it "renders merchant account navigation in the header and bottom bar" do
    login_as(merchant_user)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include('placeholder="Search marketplace"')
    expect(response.body).to include("Dashboard")
    expect(response.body).to include("Catalog")
    expect(response.body).to include("Products")
    expect(response.body).to include("Inventory")
    expect(response.body).to include("Services")
    expect(response.body).to include("Analytics")

    bottom_nav = body_doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Dashboard", "Catalog", "Products", "Inventory", "Profile")
    expect(bottom_nav.text).not_to include("Search")
    expect(response.body).to include("theme-merchant")
  end

  it "renders customer navigation with home and cart actions" do
    login_as(customer_user)

    get catalog_path

    expect(response).to have_http_status(:success)
    bottom_nav = body_doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Home", "Shop", "Services", "Cart", "Profile")
    expect(bottom_nav.text).not_to include("Search")
    expect(body_doc.at_css(".topbar").text).to include("Cart")
    expect(response.body).to include("theme-customer")
  end

  it "renders a customer profile hub with prominent orders and bookings" do
    login_as(customer_user)

    get customer_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Orders")
    expect(response.body).to include("Bookings")
    expect(response.body).to include("Edit profile")
    expect(response.body).to include("My lists")
    expect(response.body).to include("Inbox")
    expect(response.body).to include("Notifications")
    expect(response.body).to include("Settings")
    expect(response.body).to include("Help")
    expect(response.body).to include("Contact us")
    expect(response.body).to include("Sign out")
    expect(body_doc.at_css(".account-bottom-nav").text).to include("Profile")
  end

  it "renders a merchant profile hub with role-specific actions" do
    account = Account.create_with_owner!(creator: merchant_account_owner, name: "Merchant Account", account_type: "enterprise_merchant")
    supplier_record = Supplier.create!(name: "Merchant Co", default_lead_time_days: 7)
    MerchantProfile.create!(account: account, supplier: supplier_record, display_name: "Merchant Co")
    login_as(merchant_account_owner)

    get merchant_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Orders")
    expect(response.body).to include("Bookings")
    expect(response.body).to include("Team")
    expect(response.body).to include("Locations")
    expect(response.body).to include("Access control")
    expect(response.body).to include("Settings")
    expect(response.body).to include("theme-enterprise-merchant")
    expect(response.body).to include("merchant-profile-hub")
    expect(response.body).not_to include("Enterprise Merchant Account")
  end

  it "serves root as the public marketplace landing page for guests" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("marketplace-home-header")
    expect(response.body).to include("marketplace-home-account")
    expect(response.body).to include("marketplace-home-hero")
    expect(response.body).to include("marketplace-home-search__submit")
    expect(response.body).to include("marketplace-menu__link")
    expect(response.body).to include("Build smarter. Shop faster.")
    expect(response.body).not_to include("Marketplace / Catalog")
    expect(response.body).not_to include("topbar topbar--account")
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
    expect(response.body).not_to include("Marketplace / Catalog")
  end
end

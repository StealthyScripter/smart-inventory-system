require "rails_helper"

RSpec.describe "Profile navigation", type: :request do
  let!(:category) { Category.create!(name: "Profile Category") }
  let!(:supplier) { Supplier.create!(name: "Profile Supplier", default_lead_time_days: 7) }
  let!(:product) do
    Product.create!(
      name: "Profile Product",
      sku: "PROFILE-PRODUCT",
      category: category,
      supplier: supplier,
      marketplace_status: "public"
    )
  end

  def doc
    Nokogiri::HTML(response.body)
  end

  def build_merchant_account(owner:, account_type:)
    account = Account.create_with_owner!(creator: owner, name: "#{account_type.humanize} Account", account_type: account_type)
    MerchantProfile.create!(account: account, supplier: supplier, display_name: "#{account_type.humanize} Shop")
    account
  end

  it "redirects guests away from customer profile" do
    get customer_profile_path

    expect(response).to redirect_to(login_path)
  end

  it "shows customer profile actions and hides old header clutter" do
    customer = create_authenticated_user(role: "customer", email: "customer.profile@example.com")
    Notification.create!(user: customer, event_type: "test", title: "Unread")
    login_as(customer)

    get customer_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("theme-customer")
    expect(response.body).to include("Orders")
    expect(response.body).to include("Bookings")
    expect(response.body).to include("Edit profile")
    expect(response.body).to include("Manage lists")
    expect(response.body).to include("Sign out")
    expect(response.body).to include("placeholder=\"Search marketplace\"")

    topbar_text = doc.at_css(".topbar").text
    expect(topbar_text).not_to include(customer.full_name)
    expect(topbar_text).not_to include("Inbox")
    expect(topbar_text).not_to include("Notifications")
    expect(topbar_text).not_to include("Logout")
    expect(topbar_text).to include("Cart")

    primary_cards = doc.css(".profile-grid--primary .profile-feature-card")
    expect(primary_cards.size).to eq(2)
    expect(primary_cards.map(&:text).join(" ")).to include("Orders", "Bookings")

    bottom_nav = doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Home", "Shop", "Services", "Cart", "Profile")
    expect(bottom_nav.text).not_to include("Search")
    expect(bottom_nav.css(".account-bottom-nav__label").any?).to be(true)
  end

  it "allows individual merchants into the merchant profile and hides enterprise-only controls" do
    owner = create_authenticated_user(role: "supplier", email: "merchant.individual@example.com")
    build_merchant_account(owner: owner, account_type: "individual_merchant")
    login_as(owner)

    get merchant_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("theme-merchant")
    expect(response.body).to include("Orders")
    expect(response.body).to include("Bookings")
    expect(response.body).to include("Catalog / listings")
    expect(response.body).not_to include("Team / members")
    expect(response.body).not_to include("Locations")
    expect(response.body).not_to include("Access control")

    primary_cards = doc.css(".profile-grid--primary .profile-feature-card")
    expect(primary_cards.size).to eq(2)
    expect(primary_cards.map(&:text).join(" ")).to include("Orders", "Bookings")

    bottom_nav = doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Dashboard", "Catalog", "Products", "Inventory", "Profile")
    expect(bottom_nav.text).not_to include("Search")
  end

  it "renders the merchant catalog hub without duplicate search or breadcrumb clutter" do
    owner = create_authenticated_user(role: "supplier", email: "merchant.catalog@example.com")
    build_merchant_account(owner: owner, account_type: "individual_merchant")
    login_as(owner)

    get merchant_catalog_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Products")
    expect(response.body).to include("Services")
    expect(response.body).to include("placeholder=\"Search marketplace\"")
    expect(response.body).not_to include("Marketplace / Catalog")
    expect(response.body.scan('placeholder="Search marketplace"').size).to eq(1)
  end

  it "exposes enterprise-only controls on the merchant profile" do
    owner = create_authenticated_user(role: "customer", email: "merchant.enterprise@example.com")
    build_merchant_account(owner: owner, account_type: "enterprise_merchant")
    login_as(owner)

    get merchant_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("theme-enterprise")
    expect(response.body).to include("Team / members")
    expect(response.body).to include("Locations")
    expect(response.body).to include("Access control")
    expect(response.body).to include("Edit profile")
    expect(response.body).to include("Catalog / listings")
    expect(doc.css(".profile-grid .profile-company-card").size).to eq(1)
  end

  it "removes breadcrumbs and secondary search bars from marketplace pages" do
    customer = create_authenticated_user(role: "customer", email: "layout.customer@example.com")
    login_as(customer)

    get catalog_path

    expect(response.body).not_to include("Marketplace / Catalog")
    expect(response.body).not_to include("Marketplace / Search")
    expect(response.body.scan('placeholder="Search marketplace"').size).to eq(1)
    expect(doc.css(".topbar").size).to eq(1)
  end

  it "renders merchant and customer bottom navigation with icon classes" do
    customer = create_authenticated_user(role: "customer", email: "icon.customer@example.com")
    login_as(customer)

    get customer_profile_path
    expect(response.body).to include("account-bottom-nav__label")
    expect(response.body).to include("nav-icon")

    merchant = create_authenticated_user(role: "supplier", email: "icon.merchant@example.com")
    build_merchant_account(owner: merchant, account_type: "individual_merchant")
    login_as(merchant)

    get merchant_profile_path
    expect(response.body).to include("account-bottom-nav__label")
    expect(response.body).to include("nav-icon")
  end
end

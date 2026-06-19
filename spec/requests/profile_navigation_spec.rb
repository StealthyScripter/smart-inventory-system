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

  def build_merchant_account(owner:, account_type:, supplier_record: supplier)
    account = Account.create_with_owner!(creator: owner, name: "#{account_type.humanize} Account", account_type: account_type)
    MerchantProfile.create!(account: account, supplier: supplier_record, display_name: "#{account_type.humanize} Shop")
    account
  end

  it "redirects guests away from customer profile" do
    get customer_profile_path

    expect(response).to redirect_to(login_path)
  end

  it "renders the customer profile commerce layout in the required order" do
    customer = create_authenticated_user(
      role: "customer",
      first_name: "Casey",
      last_name: "Customer",
      email: "customer.profile@example.com"
    )
    Notification.create!(user: customer, event_type: "test", title: "Unread")
    login_as(customer)

    get customer_profile_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("theme-customer")
    profile = doc.at_css(".customer-profile")
    expect(profile.at_css(".customer-profile__name").text.strip).to eq(customer.full_name)
    expect(profile.css(".badge")).to be_empty
    expect(profile.text).not_to include("#{customer.full_name} Account")
    expect(profile.at_css(".customer-profile__avatar").text.strip).to eq("CC")
    expect(response.body).to include("placeholder=\"Search marketplace\"")

    primary_actions = profile.css(".customer-profile__primary-action")
    expect(primary_actions.map { |action| action.at_css("span").text.strip }).to eq(["Orders", "Bookings"])
    expect(primary_actions.map { |action| action["href"] }).to eq(
      [customer_orders_path, customer_service_bookings_path]
    )

    list_labels = profile.css(".customer-profile__list .customer-profile__row-label").map { |label| label.text.strip }
    expect(list_labels).to eq(
      ["Edit profile", "My lists", "Inbox", "Notifications", "Settings", "Help", "Contact us", "Sign out"]
    )

    topbar_text = doc.at_css(".topbar").text
    expect(topbar_text).not_to include(customer.full_name)
    expect(topbar_text).not_to include("Inbox")
    expect(topbar_text).not_to include("Notifications")
    expect(topbar_text).not_to include("Logout")
    expect(topbar_text).to include("Cart")

    bottom_nav = doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Home", "Shop", "Services", "Cart", "Profile")
    expect(bottom_nav.text).not_to include("Search")
    expect(bottom_nav.css(".account-bottom-nav__label").any?).to be(true)
  end

  it "blocks merchants from the customer profile" do
    merchant = create_authenticated_user(role: "supplier", email: "merchant.customer.profile@example.com")
    SupplierUser.create!(supplier: supplier, user: merchant)
    login_as(merchant)

    get customer_profile_path

    expect(response).to have_http_status(:forbidden)
  end

  it "allows individual merchants into the merchant profile and hides enterprise-only controls" do
    owner = create_authenticated_user(role: "supplier", email: "merchant.individual@example.com")
    build_merchant_account(owner: owner, account_type: "individual_merchant")
    login_as(owner)

    get merchant_profile_path

    expect(response).to have_http_status(:success)
    expect(doc.at_css("body")["class"]).to include("theme-individual-merchant")
    profile = doc.at_css(".merchant-profile-hub")
    expect(profile).to be_present
    expect(profile.at_css(".customer-profile__name").text.strip).to eq("Individual merchant Shop")
    expect(profile.css(".badge")).to be_empty
    expect(profile.text).not_to include("Individual Merchant Account")
    expect(profile.css(".profile-subtitle")).to be_empty

    primary_actions = profile.css(".customer-profile__primary-action")
    expect(primary_actions.map { |action| action.at_css("span").text.strip }).to eq(["Orders", "Bookings"])

    list_labels = profile.css(".customer-profile__row-label").map { |label| label.text.strip }
    expect(list_labels).to eq(
      ["Edit profile", "Catalog", "Products", "Inventory", "Inbox", "Notifications", "Analytics", "Settings", "Help", "Contact us", "Sign out"]
    )
    expect(profile.text).not_to include("Team")
    expect(profile.text).not_to include("Locations")
    expect(profile.text).not_to include("Access control")
    expect(profile.css(".tabs, .tab-strip, .profile-tabs")).to be_empty

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
    expect(doc.at_css("body")["class"]).to include("theme-enterprise-merchant")
    profile = doc.at_css(".merchant-profile-hub")
    expect(profile).to be_present
    expect(profile.at_css(".customer-profile__name").text.strip).to eq("Enterprise merchant Shop")
    expect(profile.css(".badge")).to be_empty
    expect(profile.text).not_to include("Enterprise Merchant Account")
    expect(profile.css(".profile-subtitle")).to be_empty

    list_labels = profile.css(".customer-profile__row-label").map { |label| label.text.strip }
    expect(list_labels).to eq(
      ["Edit company profile", "Catalog", "Products", "Inventory", "Team", "Locations", "Access control", "Inbox", "Notifications", "Analytics", "Settings", "Help", "Contact us", "Sign out"]
    )
    expect(profile.css(".tabs, .tab-strip, .profile-tabs")).to be_empty
  end

  it "limits the enterprise employee profile and bottom navigation to permitted links" do
    owner = create_authenticated_user(role: "customer", email: "merchant.employee.owner@example.com")
    employee = create_authenticated_user(role: "customer", email: "merchant.employee@example.com")
    employee_supplier = Supplier.create!(name: "Employee Profile Supplier", default_lead_time_days: 7)
    account = build_merchant_account(owner: owner, account_type: "enterprise_merchant", supplier_record: employee_supplier)
    account.account_memberships.create!(user: employee, role: "employee")
    login_as(employee)

    get merchant_profile_path

    expect(response).to have_http_status(:success)
    profile = doc.at_css(".merchant-profile-hub")
    expect(profile).to be_present
    expect(profile.css(".customer-profile__primary-action").map { |action| action.at_css("span").text.strip }).to eq(["Orders"])

    list_labels = profile.css(".customer-profile__row-label").map { |label| label.text.strip }
    expect(list_labels).to eq(["Inventory", "Inbox", "Notifications", "Analytics", "Help", "Contact us", "Sign out"])
    expect(profile.text).not_to include("Catalog")
    expect(profile.text).not_to include("Products")
    expect(profile.text).not_to include("Team")
    expect(profile.text).not_to include("Locations")
    expect(profile.text).not_to include("Access control")
    expect(profile.text).not_to include("Settings")

    expect(doc.at_css(".account-bottom-nav").text).to include("Dashboard", "Inventory", "Orders", "Profile")
    expect(doc.at_css(".account-bottom-nav").text).not_to include("Catalog", "Products")
  end

  it "renders modern dashboard cards for individual and enterprise merchants" do
    individual = create_authenticated_user(role: "supplier", email: "dashboard.individual@example.com")
    build_merchant_account(owner: individual, account_type: "individual_merchant")
    login_as(individual)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(doc.at_css("body")["class"]).to include("theme-individual-merchant")
    expect(doc.at_css(".merchant-dashboard .merchant-page-header")).to be_present
    expect(doc.css(".merchant-metric-card").size).to eq(6)
    expect(response.body).not_to include("Team")
    expect(response.body).not_to include("Settings")

    enterprise = create_authenticated_user(role: "customer", email: "dashboard.enterprise@example.com")
    enterprise_supplier = Supplier.create!(name: "Dashboard Enterprise Supplier", default_lead_time_days: 7)
    build_merchant_account(owner: enterprise, account_type: "enterprise_merchant", supplier_record: enterprise_supplier)
    login_as(enterprise)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(doc.at_css("body")["class"]).to include("theme-enterprise-merchant")
    expect(doc.at_css(".merchant-dashboard .merchant-page-header")).to be_present
    expect(response.body).to include("Team")
    expect(response.body).to include("Settings")
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

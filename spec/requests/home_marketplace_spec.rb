require "rails_helper"

RSpec.describe "Home marketplace", type: :request do
  let!(:category) { Category.create!(name: "Home Goods") }
  let!(:secondary_category) { Category.create!(name: "Building Materials") }
  let!(:supplier) { Supplier.create!(name: "Home Merchant", default_lead_time_days: 7, shop_status: "public") }
  let!(:secondary_supplier) { Supplier.create!(name: "Project Merchant", default_lead_time_days: 7, shop_status: "public") }
  let!(:public_product) do
    Product.create!(
      name: "Home Product",
      sku: "HOME-PRODUCT",
      category: category,
      supplier: supplier,
      selling_price: 25,
      marketplace_status: "public"
    )
  end
  let!(:building_product) do
    Product.create!(
      name: "Project Board",
      sku: "PROJECT-BOARD",
      category: secondary_category,
      supplier: secondary_supplier,
      selling_price: 50,
      marketplace_status: "public"
    )
  end
  let!(:private_product) do
    Product.create!(
      name: "Private Home Product",
      sku: "HOME-PRIVATE",
      category: category,
      supplier: supplier,
      selling_price: 30,
      marketplace_status: "private",
      listing_scope: "local"
    )
  end
  let!(:public_service) do
    ServiceListing.create!(
      supplier: supplier,
      name: "Home Service",
      service_category: ServiceListing::CATEGORIES.first,
      status: "public",
      visibility: "public",
      starting_price: 40
    )
  end
  let!(:private_service) do
    ServiceListing.create!(
      supplier: supplier,
      name: "Private Home Service",
      service_category: ServiceListing::CATEGORIES.first,
      status: "draft",
      visibility: "private",
      starting_price: 45
    )
  end

  def doc
    Nokogiri::HTML(response.body)
  end

  it "is accessible to guests" do
    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Build smarter. Shop faster.")
    expect(response.body).to include("Search products, services, merchants")
    expect(response.body).to include("Sign in")
    expect(response.body).to include("Account")
    expect(response.body).to include("Cart")
  end

  it "is accessible to authenticated customers" do
    customer = create_authenticated_user(role: "customer", first_name: "Chris", last_name: "Customer", email: "home.customer@example.com")
    login_as(customer)

    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Hi, Chris")
    expect(response.body).to include("Account")
    expect(response.body).not_to include("Customer Account")
    expect(response.body).to include(customer_profile_path)
  end

  it "renders a marketplace header and menu strip" do
    get root_path

    expect(response.body).to include("marketplace-home-header")
    expect(response.body).to include("marketplace-home-search")
    expect(response.body).to include("marketplace-home-hero")
    expect(response.body).to include("marketplace-home-promo")
    expect(response.body).to include("marketplace-rail")
    expect(response.body).to include("marketplace-menu__link")
    expect(response.body).to include("Departments")
    expect(response.body).to include("Services")
    expect(response.body).to include("Deals")
    expect(response.body).to include("Merchants")
    expect(response.body).to include("Search")
  end

  it "renders the marketplace sections" do
    get root_path

    expect(response.body).to include("Marketplace merchants")
    expect(response.body).not_to include("Discover great brands")
    expect(response.body).not_to include("Top merchants")
    expect(response.body).to include("General supplies")
    expect(response.body).not_to include("Construction essentials")
    expect(response.body).not_to include("Electrical supplies")
    expect(response.body).not_to include("Plumbing products")
    expect(response.body).not_to include("Paint and finishing")
    expect(response.body).to include("General services")
    expect(response.body).not_to include("Interior design services")
    expect(response.body).not_to include("HVAC services")
    expect(response.body).not_to include("Home and interior services")
    expect(response.body).to include("Recently added")
  end

  it "builds marketplace sections dynamically from backend tags only when they can fill a row" do
    section_tag = Tag.create!(name: "Project essentials", context: "category")
    underfilled_tag = Tag.create!(name: "Father's Day", context: "event")
    building_product.tags << section_tag
    public_product.tags << underfilled_tag

    3.times do |index|
      product = Product.create!(
        name: "Project Board #{index + 2}",
        sku: "PROJECT-BOARD-#{index + 2}",
        category: secondary_category,
        supplier: secondary_supplier,
        selling_price: 50 + index,
        marketplace_status: "public"
      )
      product.tags << section_tag
    end

    get root_path

    expect(response.body).to include("Project essentials")
    expect(response.body).to include(search_path(tag_id: section_tag.id))
    expect(response.body).not_to include("Father's Day")

    get search_path(tag_id: section_tag.id)

    expect(response.body).to include(building_product.name)
    expect(response.body).not_to include(public_product.name)
  end

  it "builds dynamic service and merchant sections from the same tag system" do
    service_tag = Tag.create!(name: "Rapid response services", context: "condition")
    merchant_tag = Tag.create!(name: "Local project partners", context: "supplier")
    public_service.tags << service_tag
    supplier.tags << merchant_tag
    secondary_supplier.tags << merchant_tag

    3.times do |index|
      provider = Supplier.create!(
        name: "Response Merchant #{index + 1}",
        default_lead_time_days: 3,
        shop_status: "public"
      )
      provider.tags << merchant_tag if index < 2
      ServiceListing.create!(
        supplier: provider,
        name: "Rapid Service #{index + 1}",
        service_category: "Plumbing",
        status: "public",
        visibility: "public"
      ).tags << service_tag
    end

    get root_path

    expect(response.body).to include("Rapid response services")
    expect(response.body).to include("Local project partners")
  end

  it "hides non-public listings from the landing page" do
    archived_product = Product.create!(
      name: "Archived Home Product",
      sku: "HOME-ARCHIVED",
      category: category,
      supplier: supplier,
      selling_price: 70,
      marketplace_status: "archived",
      listing_scope: "marketplace"
    )

    get root_path

    expect(response.body).to include(public_product.name)
    expect(response.body).to include(building_product.name)
    expect(response.body).to include(public_service.name)
    expect(response.body).not_to include(private_product.name)
    expect(response.body).not_to include(private_service.name)
    expect(response.body).not_to include(archived_product.name)
  end

  it "renders the customer bottom nav with Home first" do
    customer = create_authenticated_user(role: "customer", email: "home.customer.nav@example.com")
    login_as(customer)

    get root_path

    bottom_nav = doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Home", "Shop", "Services", "Cart", "Profile")
    expect(doc.at_css(".account-bottom-nav__link").text).to include("Home")
  end
end

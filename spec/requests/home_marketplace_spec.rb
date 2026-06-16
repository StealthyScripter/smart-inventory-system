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
    expect(response.body).to include("Sign in / Account")
    expect(response.body).to include("Cart")
  end

  it "is accessible to authenticated customers" do
    customer = create_authenticated_user(role: "customer", email: "home.customer@example.com")
    login_as(customer)

    get root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(customer.full_name)
    expect(response.body).to include(customer_profile_path)
  end

  it "renders a marketplace header and menu strip" do
    get root_path

    expect(response.body).to include("marketplace-home-header")
    expect(response.body).to include("marketplace-home-search")
    expect(response.body).to include("marketplace-home-hero")
    expect(response.body).to include("marketplace-rail")
    expect(response.body).to include("marketplace-menu__link")
    expect(response.body).to include("Departments")
    expect(response.body).to include("Services")
    expect(response.body).to include("Deals")
    expect(response.body).to include("Merchants")
  end

  it "renders the marketplace sections" do
    get root_path

    expect(response.body).to include("Discover great brands")
    expect(response.body).to include("Popular goods")
    expect(response.body).to include("Construction essentials")
    expect(response.body).to include("Electrical supplies")
    expect(response.body).to include("Plumbing products")
    expect(response.body).to include("Paint and finishing")
    expect(response.body).to include("Trending services")
    expect(response.body).to include("Interior design services")
    expect(response.body).to include("HVAC services")
    expect(response.body).to include("Services near you")
    expect(response.body).to include("Top merchants")
    expect(response.body).to include("Recently added")
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

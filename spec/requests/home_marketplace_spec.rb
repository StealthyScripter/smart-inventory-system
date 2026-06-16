require "rails_helper"

RSpec.describe "Home marketplace", type: :request do
  let!(:category) { Category.create!(name: "Home Goods") }
  let!(:supplier) { Supplier.create!(name: "Home Merchant", default_lead_time_days: 7, shop_status: "public") }
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
    expect(response.body).to include("Browse goods, services, and merchants in one place.")
  end

  it "renders marketplace landing sections" do
    get root_path

    expect(response.body).to include("Goods")
    expect(response.body).to include("Services")
    expect(response.body).to include("Merchants")
    expect(response.body).to include("Recommended")
    expect(response.body).to include("Top rated")
    expect(response.body).to include("Recently added")
  end

  it "hides non-public listings from the landing page" do
    get root_path

    expect(response.body).to include(public_product.name)
    expect(response.body).to include(public_service.name)
    expect(response.body).not_to include(private_product.name)
    expect(response.body).not_to include(private_service.name)
  end

  it "renders the customer bottom nav with Home first" do
    customer = create_authenticated_user(role: "customer", email: "home.customer@example.com")
    login_as(customer)

    get root_path

    bottom_nav = doc.at_css(".account-bottom-nav")
    expect(bottom_nav.text).to include("Home", "Shop", "Services", "Cart", "Profile")
    expect(doc.at_css(".account-bottom-nav__link").text).to include("Home")
  end
end

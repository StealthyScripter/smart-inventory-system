require "rails_helper"

RSpec.describe "Advanced marketplace search", type: :request do
  let!(:category) { Category.create!(name: "Search Hardware") }
  let!(:other_category) { Category.create!(name: "Search Electrical") }
  let!(:supplier) do
    Supplier.create!(
      name: "Search Merchant",
      default_lead_time_days: 7,
      shop_status: "public",
      shop_description: "Trusted building materials",
      search_tags: "trusted local contractor"
    )
  end
  let!(:other_supplier) { Supplier.create!(name: "Other Search Merchant", default_lead_time_days: 7, shop_status: "public") }
  let!(:public_product) do
    Product.create!(
      name: "Anchor Bolt",
      sku: "SEARCH-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      selling_price: 8,
      search_tags: "fasteners masonry"
    )
  end
  let!(:private_product) do
    Product.create!(
      name: "Private Anchor",
      sku: "PRIVATE-ANCHOR",
      category: category,
      supplier: supplier,
      marketplace_status: "private",
      search_tags: "fasteners hidden"
    )
  end
  let!(:service) do
    ServiceListing.create!(
      supplier: supplier,
      name: "Precision Plumbing",
      service_category: "Plumbing",
      status: "public",
      starting_price: 90,
      search_tags: "pipes repair"
    )
  end
  let!(:draft_service) do
    ServiceListing.create!(
      supplier: supplier,
      name: "Draft Plumbing",
      service_category: "Plumbing",
      status: "draft",
      search_tags: "pipes"
    )
  end

  it "searches products, services, merchants, and categories while respecting public visibility" do
    get search_path, params: { q: "fasteners" }

    expect(response).to have_http_status(:success)
    expect(response.body).to include(public_product.name)
    expect(response.body).not_to include(private_product.name)
    expect(response.body).not_to include(draft_service.name)
  end

  it "finds services and merchants by searchable metadata" do
    get search_path, params: { q: "pipes" }

    expect(response.body).to include(service.name)
    expect(response.body).not_to include(draft_service.name)

    get search_path, params: { q: "trusted" }

    expect(response.body).to include(supplier.name)
  end

  it "filters by service category and merchant" do
    other_service = ServiceListing.create!(
      supplier: other_supplier,
      name: "Electrical Install",
      service_category: "Electrical",
      status: "public"
    )

    get search_path, params: { service_category: "Plumbing", merchant_id: supplier.id }

    expect(response.body).to include(service.name)
    expect(response.body).not_to include(other_service.name)
  end

  it "sorts product results by price" do
    cheaper = Product.create!(
      name: "Cheap Anchor",
      sku: "SEARCH-CHEAP",
      category: other_category,
      supplier: supplier,
      marketplace_status: "public",
      selling_price: 2
    )

    get search_path, params: { q: "Anchor", sort: "price_asc" }

    expect(response.body.index(cheaper.name)).to be < response.body.index(public_product.name)
  end
end

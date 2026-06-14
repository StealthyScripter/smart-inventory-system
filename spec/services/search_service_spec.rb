require "rails_helper"

RSpec.describe SearchService do
  let!(:category) { Category.create!(name: "Discovery Category") }
  let!(:supplier) { Supplier.create!(name: "Discovery Merchant", default_lead_time_days: 7, shop_status: "public") }
  let!(:customer) { create_user(role: "customer", email: "search.service.customer@example.com") }
  let!(:product) do
    Product.create!(
      name: "Discovery Paint",
      sku: "DISC-PAINT",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      search_tags: "coating finish"
    )
  end
  let!(:hidden_product) do
    Product.create!(
      name: "Hidden Discovery Paint",
      sku: "DISC-HIDDEN",
      category: category,
      supplier: supplier,
      marketplace_status: "draft",
      search_tags: "coating"
    )
  end
  let!(:service) do
    ServiceListing.create!(
      supplier: supplier,
      name: "Discovery Painting",
      service_category: "Painting",
      status: "public",
      search_tags: "coating"
    )
  end

  it "returns suggestions from public searchable records" do
    suggestions = described_class.new(q: "coating").suggestions

    expect(suggestions).to include(product.name, service.name)
    expect(suggestions).not_to include(hidden_product.name)
  end

  it "keeps related products scoped to public marketplace listings" do
    related = Product.create!(
      name: "Related Paint Brush",
      sku: "DISC-BRUSH",
      category: category,
      supplier: supplier,
      marketplace_status: "public"
    )

    results = described_class.new.related_products(product)

    expect(results).to include(related)
    expect(results).not_to include(hidden_product)
  end

  it "keeps related services scoped to public service listings" do
    hidden_service = ServiceListing.create!(supplier: supplier, name: "Hidden Painting", service_category: "Painting", status: "draft")
    related = ServiceListing.create!(supplier: supplier, name: "Related Painting", service_category: "Painting", status: "public")

    results = described_class.new.related_services(service)

    expect(results).to include(related)
    expect(results).not_to include(hidden_service)
  end

  def create_user(attributes = {})
    User.create!(
      {
        first_name: "Search",
        last_name: "User",
        email: "search#{rand(1000..9999)}@example.com",
        role: "customer",
        password: "password123",
        password_confirmation: "password123"
      }.merge(attributes)
    )
  end
end

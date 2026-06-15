require "rails_helper"

RSpec.describe "Marketplace listing separation", type: :request do
  let!(:category) { Category.create!(name: "Listing Separation Category") }
  let!(:supplier) { Supplier.create!(name: "Listing Separation Supplier", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "listing.separation.merchant@example.com") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "shows public catalog products through visible marketplace listings" do
    product = Product.create!(
      name: "Visible Listing Product",
      sku: "VISIBLE-LISTING",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace"
    )

    get catalog_path

    expect(product.marketplace_listing).to be_visible
    expect(response.body).to include(product.name)
  end

  it "does not show hidden listings in the public catalog" do
    product = Product.create!(
      name: "Catalog Hidden Listing",
      sku: "CATALOG-HIDDEN-LISTING",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace"
    )
    product.marketplace_listing.update!(visibility: "private")

    get catalog_path

    expect(response.body).not_to include(product.name)
  end

  it "lets merchants manage listing fields separately from inventory fields" do
    product = Product.create!(
      name: "Internal Inventory Name",
      sku: "INTERNAL-LISTING-SKU",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace",
      unit_cost: 4.25
    )
    login_as(merchant)

    patch merchant_product_path(product), params: {
      product: {
        name: product.name,
        sku: product.sku,
        category_id: category.id,
        supplier_id: supplier.id,
        listing_scope: "marketplace",
        reorder_point: product.reorder_point,
        lead_time_days: product.lead_time_days,
        unit_cost: product.unit_cost
      },
      marketplace_listing: {
        title: "Public Listing Name",
        public_description: "Public listing details",
        public_price: 12.75,
        sale_price: 10.25,
        availability: "available",
        status: "active",
        visibility: "public",
        shipping_eligible: true,
        search_tags: "public tags"
      }
    }

    expect(response).to redirect_to(merchant_products_path)
    expect(product.reload.name).to eq("Internal Inventory Name")
    expect(product.sku).to eq("INTERNAL-LISTING-SKU")
    expect(product.unit_cost).to eq(4.25)
    expect(product.marketplace_listing.title).to eq("Public Listing Name")
    expect(product.marketplace_listing.current_price).to eq(10.25)
  end
end

require "rails_helper"

RSpec.describe "Marketplace listing separation", type: :request do
  let!(:category) { Category.create!(name: "Listing Separation Category") }
  let!(:supplier) { Supplier.create!(name: "Listing Separation Supplier", default_lead_time_days: 7) }

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
end

require "rails_helper"

RSpec.describe MarketplaceListing, type: :model do
  let(:category) { Category.create!(name: "Listing Category") }
  let(:supplier) { Supplier.create!(name: "Listing Supplier", default_lead_time_days: 7) }

  it "allows products to exist without marketplace listings" do
    product = Product.create!(
      name: "Local Only Listing Product",
      sku: "LOCAL-ONLY-LISTING",
      category: category,
      supplier: supplier,
      marketplace_status: "private",
      listing_scope: "local"
    )

    expect(product.marketplace_listing).to be_nil
  end

  it "creates a visible marketplace listing for public marketplace products" do
    product = Product.create!(
      name: "Public Listing Product",
      sku: "PUBLIC-LISTING",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace",
      selling_price: 15
    )

    listing = product.marketplace_listing
    expect(listing).to be_visible
    expect(listing.title).to eq(product.name)
    expect(listing.public_price).to eq(15)
  end

  it "hides a listing without deleting the inventory product" do
    product = Product.create!(
      name: "Hidden Listing Product",
      sku: "HIDDEN-LISTING",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace"
    )

    product.marketplace_listing.update!(status: "hidden")

    expect(Product.exists?(product.id)).to be(true)
    expect(Product.publicly_listed).not_to include(product)
  end
end

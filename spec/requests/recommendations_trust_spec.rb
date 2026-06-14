require "rails_helper"

RSpec.describe "Recommendations and trust layer", type: :request do
  let!(:category) { Category.create!(name: "Trust Category") }
  let!(:supplier) { Supplier.create!(name: "Trust Merchant", default_lead_time_days: 7) }
  let!(:customer) { create_authenticated_user(role: "customer", email: "trust.customer@example.com") }
  let!(:product) { Product.create!(name: "Anchor Product", sku: "TRUST-ANCHOR", category: category, supplier: supplier, marketplace_status: "public") }
  let!(:recommended) { Product.create!(name: "Recommended Product", sku: "TRUST-REC", category: category, supplier: supplier, marketplace_status: "public") }

  it "shows related product recommendations" do
    get catalog_product_path(product)

    expect(response.body).to include("Recommended Product")
  end

  it "shows verified purchase trust badges for delivered product reviews" do
    order = Order.create!(user: customer, status: "delivered", total_amount: 1)
    item = order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 1, total_amount: 1, fulfillment_status: "delivered")
    Review.create!(user: customer, product: product, supplier: supplier, order_item: item, rating: 5, body: "Good")

    get catalog_product_path(product)

    expect(response.body).to include("Verified Purchase")
  end

  it "shows related service recommendations" do
    service = ServiceListing.create!(supplier: supplier, name: "Base Cleaning", service_category: "Cleaning", status: "public")
    ServiceListing.create!(supplier: supplier, name: "Recommended Cleaning", service_category: "Cleaning", status: "public")

    get service_path(service)

    expect(response.body).to include("Recommended Cleaning")
  end
end

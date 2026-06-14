require "rails_helper"

RSpec.describe AnalyticsSummary do
  it "summarizes merchant metrics for scoped suppliers" do
    category = Category.create!(name: "Analytics")
    supplier = Supplier.create!(name: "Analytics Supplier", default_lead_time_days: 7)
    product = Product.create!(name: "Analytics Product", sku: "ANALYTICS-PRODUCT", category: category, supplier: supplier, marketplace_status: "public")
    service = ServiceListing.create!(supplier: supplier, name: "Analytics Service", service_category: "Cleaning", status: "public")
    customer = User.create!(
      first_name: "Analytics",
      last_name: "Customer",
      email: "analytics.summary.customer@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
    order = Order.create!(user: customer, status: "delivered", total_amount: 12)
    item = order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 12, total_amount: 12, fulfillment_status: "delivered")
    Review.create!(user: customer, product: product, supplier: supplier, order_item: item, rating: 5)

    summary = described_class.for_merchant(Supplier.where(id: supplier.id))

    expect(summary[:sales_total]).to eq(12)
    expect(summary[:public_product_count]).to eq(1)
    expect(summary[:public_service_count]).to eq(1)
    expect(summary[:review_count]).to eq(1)
    expect(service).to be_present
  end
end

require "rails_helper"

RSpec.describe "Reviews and analytics", type: :request do
  let!(:category) { Category.create!(name: "Review Hardware") }
  let!(:supplier) { Supplier.create!(name: "Review Merchant", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Review Merchant", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "review.merchant@example.com") }
  let!(:merchant_link) { SupplierUser.create!(supplier: supplier, user: merchant_user) }
  let!(:customer) { create_authenticated_user(role: "customer", email: "review.customer@example.com") }
  let!(:other_customer) { create_authenticated_user(role: "customer", email: "other.review.customer@example.com") }
  let!(:product) do
    Product.create!(name: "Review Bolt", sku: "REVIEW-BOLT", category: category, supplier: supplier, marketplace_status: "public")
  end
  let!(:other_product) do
    Product.create!(name: "Other Review Bolt", sku: "OTHER-REVIEW-BOLT", category: category, supplier: other_supplier, marketplace_status: "public")
  end
  let!(:order) { Order.create!(user: customer, status: "delivered", total_amount: 10) }
  let!(:order_item) do
    order.order_items.create!(
      product: product,
      supplier: supplier,
      quantity: 1,
      unit_price: 10,
      total_amount: 10,
      fulfillment_status: "delivered"
    )
  end

  it "allows customers to review delivered purchased products" do
    login_as(customer)

    expect do
      post reviews_path, params: { order_item_id: order_item.id, order_id: order.id, review: { rating: 5, body: "Reliable" } }
    end.to change(Review, :count).by(1)

    review = Review.last
    expect(review.product).to eq(product)
    expect(review.supplier).to eq(supplier)
  end

  it "prevents reviewing products the customer did not purchase" do
    login_as(other_customer)

    expect do
      post reviews_path, params: { order_item_id: order_item.id, order_id: order.id, review: { rating: 4, body: "Nope" } }
    end.not_to change(Review, :count)
  end

  it "prevents duplicate reviews for the same order item" do
    Review.create!(user: customer, product: product, supplier: supplier, order_item: order_item, rating: 5)
    login_as(customer)

    expect do
      post reviews_path, params: { order_item_id: order_item.id, order_id: order.id, review: { rating: 4, body: "Again" } }
    end.not_to change(Review, :count)
  end

  it "displays merchant ratings safely" do
    Review.create!(user: customer, product: product, supplier: supplier, order_item: order_item, rating: 4)

    get merchant_storefront_path(supplier)

    expect(response.body).to include("4.00")
  end

  it "scopes merchant analytics to the merchant supplier" do
    other_order = Order.create!(user: customer, status: "delivered", total_amount: 20)
    other_order.order_items.create!(product: other_product, supplier: other_supplier, quantity: 1, unit_price: 20, total_amount: 20, fulfillment_status: "delivered")
    login_as(merchant_user)

    get merchant_analytics_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("$10.00")
    expect(response.body).not_to include("$20.00")
  end

  it "scopes customer analytics to the current customer" do
    Order.create!(user: other_customer, status: "delivered", total_amount: 99)
    login_as(customer)

    get customer_analytics_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("$10.00")
    expect(response.body).not_to include("$99.00")
  end

  it "creates fulfillment notifications for customers" do
    location = Location.create!(name: "Review Warehouse")
    StockLevel.find_or_create_by!(product: product, location: location).update!(current_quantity: 5)
    actor = merchant_user
    item = OrderItem.create!(
      order: Order.create!(user: customer, status: "confirmed", total_amount: 10),
      product: product,
      supplier: supplier,
      quantity: 1,
      unit_price: 10,
      total_amount: 10,
      fulfillment_status: "packed"
    )

    expect do
      FulfillmentService.new(item, actor: actor).transition_to!("shipped")
    end.to change(Notification, :count).by(1)

    expect(customer.notifications.last.title).to eq("Order shipped")
  end
end

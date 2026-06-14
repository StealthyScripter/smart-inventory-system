require "rails_helper"

RSpec.describe "Order management", type: :request do
  let!(:category) { Category.create!(name: "Order Hardware") }
  let!(:supplier) { Supplier.create!(name: "Order Merchant", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Order Merchant", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "orders.merchant@example.com") }
  let!(:merchant_link) { SupplierUser.create!(supplier: supplier, user: merchant_user) }
  let!(:customer) { create_authenticated_user(role: "customer", email: "orders.customer@example.com") }
  let!(:other_customer) { create_authenticated_user(role: "customer", email: "other.orders.customer@example.com") }
  let!(:location) { Location.create!(name: "Order Warehouse") }
  let!(:product) do
    Product.create!(name: "Order Bolt", sku: "ORDER-BOLT", category: category, supplier: supplier, marketplace_status: "public")
  end
  let!(:other_product) do
    Product.create!(name: "Other Bolt", sku: "OTHER-ORDER-BOLT", category: category, supplier: other_supplier, marketplace_status: "public")
  end
  let!(:order) do
    Order.create!(user: customer, status: "confirmed", total_amount: 10.00).tap do |record|
      record.order_items.create!(product: product, supplier: supplier, quantity: 2, unit_price: 5.00, total_amount: 10.00)
    end
  end

  before do
    StockLevel.find_or_create_by!(product: product, location: location).update!(current_quantity: 10, reserved_quantity: 0)
    StockLevel.find_or_create_by!(product: other_product, location: location).update!(current_quantity: 10, reserved_quantity: 0)
  end

  it "allows customers to view only their own orders" do
    other_order = Order.create!(user: other_customer, status: "pending", total_amount: 1)
    login_as(customer)

    get customer_orders_path
    expect(response.body).to include(order.order_number)
    expect(response.body).not_to include(other_order.order_number)

    get customer_order_path(other_order)
    expect(response).to have_http_status(:not_found)
  end

  it "allows merchants to view only order items for their supplier" do
    other_order = Order.create!(user: customer, status: "confirmed", total_amount: 3)
    other_order.order_items.create!(product: other_product, supplier: other_supplier, quantity: 1, unit_price: 3, total_amount: 3)
    login_as(merchant_user)

    get merchant_orders_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(order.order_number)
    expect(response.body).not_to include(other_order.order_number)
  end

  it "transitions merchant order items and deducts stock when shipped" do
    item = order.order_items.first
    login_as(merchant_user)

    patch merchant_order_path(item), params: { fulfillment_status: "processing" }
    expect(item.reload.fulfillment_status).to eq("processing")

    patch merchant_order_path(item), params: { fulfillment_status: "packed" }
    expect(item.reload.fulfillment_status).to eq("packed")

    expect do
      patch merchant_order_path(item), params: { fulfillment_status: "shipped" }
    end.to change(StockMovement, :count).by(1)

    expect(item.reload.fulfillment_status).to eq("shipped")
    expect(product.stock_levels.first.current_quantity).to eq(8)
    expect(order.reload.status).to eq("shipped")
  end

  it "rejects invalid fulfillment transitions" do
    item = order.order_items.first
    login_as(merchant_user)

    patch merchant_order_path(item), params: { fulfillment_status: "shipped" }

    expect(response).to redirect_to(merchant_orders_path)
    expect(item.reload.fulfillment_status).to eq("pending")
  end

  it "prevents merchants from updating another supplier's order item" do
    other_order = Order.create!(user: customer, status: "confirmed", total_amount: 3)
    other_item = other_order.order_items.create!(product: other_product, supplier: other_supplier, quantity: 1, unit_price: 3, total_amount: 3)
    login_as(merchant_user)

    patch merchant_order_path(other_item), params: { fulfillment_status: "processing" }

    expect(response).to have_http_status(:not_found)
    expect(other_item.reload.fulfillment_status).to eq("pending")
  end
end

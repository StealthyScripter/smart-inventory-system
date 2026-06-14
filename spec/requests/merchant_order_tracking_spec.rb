require "rails_helper"

RSpec.describe "Merchant order tracking", type: :request do
  let!(:category) { Category.create!(name: "Tracking") }
  let!(:supplier) { Supplier.create!(name: "Tracking Supplier", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "tracking.merchant@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "tracking.customer@example.com") }
  let!(:location) { Location.create!(name: "Tracking Warehouse") }
  let!(:product) { Product.create!(name: "Tracked Product", sku: "TRACKED", category: category, supplier: supplier) }
  let!(:order) { Order.create!(user: customer, status: "packed", total_amount: 10) }
  let!(:order_item) do
    order.order_items.create!(
      product: product,
      supplier: supplier,
      quantity: 1,
      unit_price: 10,
      total_amount: 10,
      fulfillment_status: "packed"
    )
  end

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
    StockLevel.find_or_create_by!(product: product, location: location).update!(current_quantity: 5)
  end

  it "lets merchants attach tracking data when shipping" do
    login_as(merchant)

    patch merchant_order_path(order_item), params: {
      fulfillment_status: "shipped",
      tracking_carrier: "UPS",
      tracking_number: "1Z999",
      merchant_notes: "Packed carefully"
    }

    expect(response).to redirect_to(merchant_orders_path)
    expect(order_item.reload.tracking_carrier).to eq("UPS")
    expect(order_item.tracking_number).to eq("1Z999")
    expect(order_item.shipped_at).to be_present
  end

  it "shows tracking information to the customer" do
    order_item.update!(fulfillment_status: "shipped", tracking_carrier: "UPS", tracking_number: "1Z999")
    login_as(customer)

    get customer_order_path(order)

    expect(response.body).to include("UPS 1Z999")
  end
end

require "rails_helper"

RSpec.describe "Dormant marketplace models", type: :model do
  let(:category) { Category.create!(name: "Components") }
  let(:supplier) { Supplier.create!(name: "Industrial Supply", default_lead_time_days: 7) }
  let(:product) { Product.create!(name: "Valve", sku: "VALVE-001", category: category, supplier: supplier) }
  let(:location) { Location.create!(name: "Warehouse") }
  let(:user) do
    User.create!(
      first_name: "Purchasing",
      last_name: "Lead",
      email: "purchasing.lead@example.com",
      role: "regional_manager",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "models purchase orders and line items against existing suppliers, users, and products" do
    purchase_order = PurchaseOrder.create!(
      supplier: supplier,
      user: user,
      order_number: "PO-1001",
      order_date: Date.current,
      status: "pending",
      total_amount: 25.50
    )

    item = PurchaseOrderItem.create!(
      purchase_order: purchase_order,
      product: product,
      quantity: 3,
      unit_cost: 8.50,
      total_cost: 25.50
    )

    expect(purchase_order.purchase_order_items).to include(item)
    expect(supplier.purchase_orders).to include(purchase_order)
    expect(product.purchase_order_items).to include(item)
  end

  it "validates dormant purchasing status and quantities" do
    purchase_order = PurchaseOrder.new(
      supplier: supplier,
      user: user,
      order_number: "PO-1002",
      order_date: Date.current,
      status: "unknown"
    )
    item = PurchaseOrderItem.new(purchase_order: purchase_order, product: product, quantity: 0)

    expect(purchase_order).not_to be_valid
    expect(purchase_order.errors[:status]).to be_present
    expect(item).not_to be_valid
    expect(item.errors[:quantity]).to be_present
  end

  it "models sales transactions against existing inventory records" do
    transaction = SalesTransaction.create!(
      product: product,
      location: location,
      user: user,
      customer_name: "Acme Buyer",
      quantity: 2,
      unit_price: 12.00,
      total_amount: 24.00,
      transaction_date: Time.current
    )

    expect(product.sales_transactions).to include(transaction)
    expect(location.sales_transactions).to include(transaction)
    expect(user.sales_transactions).to include(transaction)
  end

  it "models demand forecasts with the schema unique scope" do
    DemandForecast.create!(
      product: product,
      location: location,
      forecast_date: Date.current,
      period_type: "weekly",
      predicted_demand: 12.5,
      confidence_score: 0.8
    )

    duplicate = DemandForecast.new(
      product: product,
      location: location,
      forecast_date: Date.current,
      period_type: "weekly",
      predicted_demand: 10
    )

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:product_id]).to be_present
  end
end

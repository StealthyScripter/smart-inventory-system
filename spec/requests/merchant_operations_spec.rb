require "rails_helper"

RSpec.describe "Merchant operations", type: :request do
  let!(:category) { Category.create!(name: "Merchant Ops Category") }
  let!(:supplier) { Supplier.create!(name: "Merchant Ops Supplier", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Merchant Ops Supplier", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "merchant.ops@example.com") }
  let!(:location) { Location.create!(name: "Merchant Ops Warehouse") }
  let!(:product) do
    Product.create!(
      name: "Merchant Ops Product",
      sku: "MERCH-OPS",
      category: category,
      supplier: supplier,
      marketplace_status: "draft"
    )
  end
  let!(:other_product) do
    Product.create!(
      name: "Other Merchant Ops Product",
      sku: "OTHER-MERCH-OPS",
      category: category,
      supplier: other_supplier,
      marketplace_status: "draft"
    )
  end
  let!(:stock_level) { product.stock_levels.create!(location: location, current_quantity: 3, reserved_quantity: 0) }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "renders operational dashboard summaries" do
    login_as(merchant)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Sales")
    expect(response.body).to include("Booking Queue")
    expect(response.body).to include("Upcoming Jobs")
  end

  it "bulk archives only merchant-owned products" do
    login_as(merchant)

    post merchant_product_bulk_update_path, params: {
      product_ids: [product.id, other_product.id],
      marketplace_status: "archived"
    }

    expect(response).to redirect_to(merchant_products_path)
    expect(product.reload.marketplace_status).to eq("archived")
    expect(other_product.reload.marketplace_status).to eq("draft")
  end

  it "exports merchant products as CSV" do
    login_as(merchant)

    get merchant_products_export_path(format: :csv)

    expect(response).to have_http_status(:success)
    expect(response.media_type).to eq("text/csv")
    expect(response.body).to include(product.sku)
    expect(response.body).not_to include(other_product.sku)
  end

  it "updates inventory only for merchant-owned stock levels" do
    other_stock_level = other_product.stock_levels.create!(location: location, current_quantity: 10, reserved_quantity: 0)
    login_as(merchant)

    patch merchant_inventory_item_path(stock_level), params: { stock_level: { current_quantity: 9 } }
    expect(stock_level.reload.current_quantity).to eq(9)

    patch merchant_inventory_item_path(other_stock_level), params: { stock_level: { current_quantity: 1 } }
    expect(response).to have_http_status(:not_found)
    expect(other_stock_level.reload.current_quantity).to eq(10)
  end
end

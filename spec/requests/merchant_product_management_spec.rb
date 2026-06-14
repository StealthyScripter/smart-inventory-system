require "rails_helper"

RSpec.describe "Merchant product management", type: :request do
  let!(:category) { Category.create!(name: "Components") }
  let!(:merchant_supplier) { Supplier.create!(name: "Merchant One", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Merchant Two", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "merchant@example.com") }
  let!(:merchant_link) { SupplierUser.create!(supplier: merchant_supplier, user: merchant_user) }
  let!(:merchant_product) do
    Product.create!(
      name: "Owned Valve",
      sku: "OWNED-VALVE",
      category: category,
      supplier: merchant_supplier,
      marketplace_status: "draft"
    )
  end
  let!(:other_product) do
    Product.create!(
      name: "Other Valve",
      sku: "OTHER-VALVE",
      category: category,
      supplier: other_supplier,
      marketplace_status: "public"
    )
  end

  before do
    login_as(merchant_user)
  end

  it "allows merchants to see only their own products in product management" do
    get products_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(merchant_product.name)
    expect(response.body).not_to include(other_product.name)
  end

  it "allows merchants to update their own products" do
    patch product_path(merchant_product), params: {
      product: {
        name: "Owned Valve Updated",
        sku: merchant_product.sku,
        category_id: category.id,
        supplier_id: merchant_supplier.id,
        marketplace_status: "public",
        reorder_point: 10,
        lead_time_days: 7
      }
    }

    expect(response).to redirect_to(merchant_product)
    expect(merchant_product.reload.name).to eq("Owned Valve Updated")
    expect(merchant_product.marketplace_status).to eq("public")
  end

  it "prevents merchants from updating another merchant's products" do
    patch product_path(other_product), params: {
      product: {
        name: "Hijacked Valve",
        sku: other_product.sku,
        category_id: category.id,
        supplier_id: merchant_supplier.id,
        reorder_point: 10,
        lead_time_days: 7
      }
    }

    expect(response).to redirect_to(products_path)
    expect(other_product.reload.name).to eq("Other Valve")
  end

  it "prevents merchants from assigning products to unowned suppliers" do
    patch product_path(merchant_product), params: {
      product: {
        name: merchant_product.name,
        sku: merchant_product.sku,
        category_id: category.id,
        supplier_id: other_supplier.id,
        reorder_point: 10,
        lead_time_days: 7
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(merchant_product.reload.supplier).to eq(merchant_supplier)
  end

  it "preserves admin access to all inventory products" do
    admin = create_authenticated_user(role: "admin", email: "admin.products@example.com")
    login_as(admin)

    get products_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(merchant_product.name)
    expect(response.body).to include(other_product.name)
  end
end

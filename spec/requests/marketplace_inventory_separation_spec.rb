require "rails_helper"

RSpec.describe "Marketplace and local inventory separation", type: :request do
  let!(:category) { Category.create!(name: "Scope Category") }
  let!(:supplier) { Supplier.create!(name: "Scope Supplier", default_lead_time_days: 7) }
  let!(:marketplace_product) do
    Product.create!(
      name: "Marketplace Product",
      sku: "SCOPE-MARKET",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace"
    )
  end
  let!(:local_product) do
    Product.create!(
      name: "Local Product",
      sku: "SCOPE-LOCAL",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "local"
    )
  end

  it "hides local-only products from public catalog discovery" do
    get catalog_path

    expect(response.body).to include(marketplace_product.name)
    expect(response.body).not_to include(local_product.name)
  end

  it "keeps local-only products visible to internal product management" do
    admin = create_authenticated_user(role: "admin", email: "scope.admin@example.com")
    login_as(admin)

    get products_path

    expect(response.body).to include(local_product.name)
    expect(response.body).to include("Local")
  end

  it "allows merchants to set listing scope on their products" do
    merchant = create_authenticated_user(role: "supplier", email: "scope.merchant@example.com")
    SupplierUser.create!(supplier: supplier, user: merchant)
    login_as(merchant)

    patch merchant_product_path(marketplace_product), params: {
      product: {
        name: marketplace_product.name,
        sku: marketplace_product.sku,
        category_id: category.id,
        supplier_id: supplier.id,
        marketplace_status: "public",
        listing_scope: "local",
        reorder_point: 10,
        lead_time_days: 7
      }
    }

    expect(response).to redirect_to(merchant_products_path)
    expect(marketplace_product.reload.listing_scope).to eq("local")
  end
end

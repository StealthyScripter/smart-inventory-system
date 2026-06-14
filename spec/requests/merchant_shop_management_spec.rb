require "rails_helper"

RSpec.describe "Merchant shop management", type: :request do
  let!(:supplier) { Supplier.create!(name: "Shop Merchant", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Shop", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "shop.merchant@example.com") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant_user)
  end

  it "allows linked merchants to update their shop profile" do
    login_as(merchant_user)

    patch merchant_shop_path(supplier), params: {
      supplier: {
        name: "Updated Shop",
        shop_slug: "Updated Shop",
        shop_status: "public",
        shop_description: "Custom shop profile",
        shop_image_url: "https://example.com/shop.jpg"
      }
    }

    expect(response).to redirect_to(edit_merchant_shop_path(supplier))
    expect(supplier.reload.name).to eq("Updated Shop")
    expect(supplier.shop_slug).to eq("updated-shop")
    expect(supplier.shop_status).to eq("public")
  end

  it "prevents merchants from editing another supplier shop" do
    login_as(merchant_user)

    get edit_merchant_shop_path(other_supplier)

    expect(response).to have_http_status(:not_found)
  end

  it "shows shop profile fields on the public storefront" do
    supplier.update!(
      shop_status: "public",
      shop_description: "Public-facing profile",
      shop_image_url: "https://example.com/shop.jpg"
    )

    get merchant_storefront_path(supplier)

    expect(response.body).to include("Public-facing profile")
    expect(response.body).to include("https://example.com/shop.jpg")
  end
end

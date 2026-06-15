require "rails_helper"

RSpec.describe "Merchant account access control", type: :request do
  let!(:category) { Category.create!(name: "Access Control Category") }
  let!(:supplier) { Supplier.create!(name: "Access Control Merchant", default_lead_time_days: 7) }
  let!(:location) { Location.create!(name: "Access Control Warehouse") }
  let!(:product) do
    Product.create!(
      name: "Access Control Product",
      sku: "ACCESS-CONTROL",
      category: category,
      supplier: supplier,
      marketplace_status: "draft"
    )
  end
  let!(:stock_level) { product.stock_levels.create!(location: location, current_quantity: 3, reserved_quantity: 0) }

  def account_backed_user(role:, status: "active", email: "#{role}.access@example.com")
    user = create_authenticated_user(role: "customer", email: email)
    account = Account.create!(name: "#{role} Merchant", account_type: "enterprise_merchant", status: status)
    account.account_memberships.create!(user: user, role: role)
    MerchantProfile.create!(account: account, supplier: supplier, display_name: "#{role} Merchant")
    user
  end

  it "allows catalog managers to manage catalog but not account settings" do
    user = account_backed_user(role: "catalog_manager")
    login_as(user)

    get merchant_products_path
    expect(response).to have_http_status(:success)

    get edit_merchant_shop_path(supplier)
    expect(response).to have_http_status(:forbidden)
  end

  it "allows inventory managers to view and adjust inventory but not catalog publishing tools" do
    user = account_backed_user(role: "inventory_manager")
    login_as(user)

    get merchant_inventory_path
    expect(response).to have_http_status(:success)

    patch merchant_inventory_item_path(stock_level), params: { stock_level: { current_quantity: 7 } }
    expect(response).to redirect_to(merchant_inventory_path)
    expect(stock_level.reload.current_quantity).to eq(7)

    get merchant_products_path
    expect(response).to have_http_status(:forbidden)
  end

  it "allows order managers into orders but not inventory settings" do
    customer = create_authenticated_user(role: "customer", email: "order.manager.customer@example.com")
    order = Order.create!(user: customer, status: "confirmed", total_amount: 10)
    order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 10, total_amount: 10)
    user = account_backed_user(role: "order_manager")
    login_as(user)

    get merchant_orders_path
    expect(response).to have_http_status(:success)

    get merchant_inventory_path
    expect(response).to have_http_status(:forbidden)
  end

  it "allows service managers into services and bookings" do
    user = account_backed_user(role: "service_manager")
    login_as(user)

    get merchant_services_path
    expect(response).to have_http_status(:success)

    get merchant_service_bookings_path
    expect(response).to have_http_status(:success)
  end

  it "blocks employees from admin-only shop settings" do
    user = account_backed_user(role: "employee")
    login_as(user)

    get edit_merchant_shop_path(supplier)

    expect(response).to have_http_status(:forbidden)
  end

  it "blocks suspended merchant accounts from marketplace management" do
    user = account_backed_user(role: "owner", status: "suspended")
    login_as(user)

    get merchant_products_path

    expect(response).to have_http_status(:forbidden)
  end

  it "blocks customers without merchant account membership from merchant areas" do
    user = create_authenticated_user(role: "customer", email: "plain.customer@example.com")
    login_as(user)

    get merchant_products_path

    expect(response).to have_http_status(:forbidden)
  end
end

require "rails_helper"

RSpec.describe "Account-scoped marketplace ownership", type: :request do
  let!(:category) { Category.create!(name: "Account Scoped Category") }

  def build_customer(email)
    user = create_authenticated_user(role: "customer", email: email)
    account = Account.create_with_owner!(creator: user, name: "#{email} Customer", account_type: "customer")
    CustomerProfile.create!(account: account, user: user, display_name: user.full_name)
    [user, account]
  end

  def build_merchant(email, role: "owner", account_type: "enterprise_merchant", supplier_name: email)
    user = create_authenticated_user(role: "customer", email: email)
    supplier = Supplier.create!(name: supplier_name, default_lead_time_days: 7)
    account = Account.create!(name: supplier_name, account_type: account_type)
    account.account_memberships.create!(user: user, role: role)
    MerchantProfile.create!(account: account, supplier: supplier, display_name: supplier_name)
    [user, account, supplier]
  end

  it "shows a merchant account only its own products" do
    merchant, account, supplier = build_merchant("account.product.owner@example.com", role: "catalog_manager", supplier_name: "Scoped Product Merchant")
    _other_user, other_account, other_supplier = build_merchant("account.product.other@example.com", role: "catalog_manager", supplier_name: "Other Product Merchant")
    own_product = Product.create!(name: "Own Account Product", sku: "OWN-ACCOUNT-PRODUCT", category: category, supplier: supplier, account: account)
    other_product = Product.create!(name: "Other Account Product", sku: "OTHER-ACCOUNT-PRODUCT", category: category, supplier: other_supplier, account: other_account)
    login_as(merchant)

    get merchant_products_path

    expect(response.body).to include(own_product.name)
    expect(response.body).not_to include(other_product.name)
  end

  it "shows a merchant account only its own services and bookings" do
    merchant, account, supplier = build_merchant("account.service.owner@example.com", role: "service_manager", supplier_name: "Scoped Service Merchant")
    _other_user, other_account, other_supplier = build_merchant("account.service.other@example.com", role: "service_manager", supplier_name: "Other Service Merchant")
    own_service = ServiceListing.create!(name: "Own Service", service_category: "Cleaning", supplier: supplier, account: account, status: "public")
    other_service = ServiceListing.create!(name: "Other Service", service_category: "Cleaning", supplier: other_supplier, account: other_account, status: "public")
    customer, = build_customer("booking.customer@example.com")
    own_booking = ServiceBooking.create!(user: customer, supplier: supplier, account: account)
    own_booking.service_booking_items.create!(service_listing: own_service)
    other_booking = ServiceBooking.create!(user: customer, supplier: other_supplier, account: other_account)
    other_booking.service_booking_items.create!(service_listing: other_service)
    login_as(merchant)

    get merchant_services_path
    expect(response.body).to include(own_service.name)
    expect(response.body).not_to include(other_service.name)

    get merchant_service_bookings_path
    expect(response.body).to include(own_booking.booking_number)
    expect(response.body).not_to include(other_booking.booking_number)
  end

  it "keeps local inventory out of the public catalog" do
    _merchant, account, supplier = build_merchant("local.inventory@example.com", supplier_name: "Local Inventory Merchant")
    Product.create!(
      name: "Local Account Product",
      sku: "LOCAL-ACCOUNT-PRODUCT",
      category: category,
      supplier: supplier,
      account: account,
      marketplace_status: "public",
      listing_scope: "local"
    )

    get catalog_path

    expect(response.body).not_to include("Local Account Product")
  end

  it "connects customer orders to the customer account and merchant order items to merchant accounts" do
    customer, customer_account = build_customer("account.checkout.customer@example.com")
    _merchant, merchant_account, supplier = build_merchant("account.checkout.merchant@example.com", supplier_name: "Checkout Merchant")
    product = Product.create!(
      name: "Checkout Account Product",
      sku: "CHECKOUT-ACCOUNT-PRODUCT",
      category: category,
      supplier: supplier,
      account: merchant_account,
      marketplace_status: "public",
      listing_scope: "marketplace",
      selling_price: 12
    )
    login_as(customer)

    post cart_path, params: { product_id: product.id, quantity: 1 }
    post checkout_path

    order = customer.orders.last
    order_item = order.order_items.first
    expect(order.customer_account).to eq(customer_account)
    expect(order_item.account).to eq(merchant_account)
  end

  it "lets enterprise members share account data according to permissions" do
    owner, account, supplier = build_merchant("enterprise.shared.owner@example.com", role: "owner", supplier_name: "Shared Enterprise")
    employee = create_authenticated_user(role: "customer", email: "enterprise.shared.employee@example.com")
    account.account_memberships.create!(user: employee, role: "catalog_manager")
    product = Product.create!(name: "Shared Enterprise Product", sku: "SHARED-ENTERPRISE", category: category, supplier: supplier, account: account)

    login_as(employee)
    get merchant_products_path

    expect(response.body).to include(product.name)
    expect(account.account_memberships.find_by!(user: owner)).to be_owner
  end
end

require "rails_helper"

RSpec.describe AccountBackfill do
  let!(:category) { Category.create!(name: "Backfill Category") }

  def user(email, role)
    User.create!(
      first_name: "Backfill",
      last_name: "User",
      email: email,
      role: role,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "creates customer accounts and profiles for existing customers" do
    customer = user("backfill.customer@example.com", "customer")

    described_class.call

    account = customer.customer_accounts.first
    expect(account).to be_customer
    expect(account.customer_profile.user).to eq(customer)
  end

  it "creates merchant accounts, profiles, and memberships from suppliers and supplier users" do
    owner = user("backfill.owner@example.com", "supplier")
    employee = user("backfill.employee@example.com", "supplier")
    supplier = Supplier.create!(name: "Backfill Supplier", default_lead_time_days: 7, shop_status: "public")
    SupplierUser.create!(supplier: supplier, user: owner)
    SupplierUser.create!(supplier: supplier, user: employee)

    described_class.call

    account = supplier.merchant_account
    expect(account).to be_enterprise_merchant
    expect(account.account_memberships.find_by!(user: owner)).to be_owner
    expect(account.account_memberships.find_by!(user: employee).role).to eq("employee")
  end

  it "assigns deterministic account references and listings without removing supplier links" do
    merchant = user("backfill.merchant@example.com", "supplier")
    customer = user("backfill.buyer@example.com", "customer")
    supplier = Supplier.create!(name: "Backfill Listing Supplier", default_lead_time_days: 7)
    SupplierUser.create!(supplier: supplier, user: merchant)
    product = Product.create!(
      name: "Backfill Public Product",
      sku: "BACKFILL-PUBLIC",
      category: category,
      supplier: supplier,
      marketplace_status: "public",
      listing_scope: "marketplace",
      selling_price: 20
    )
    order = Order.create!(user: customer, status: "confirmed", total_amount: 20)
    order_item = order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 20, total_amount: 20)

    described_class.call

    expect(product.reload.supplier).to eq(supplier)
    merchant_account = supplier.reload.merchant_account

    expect(product.account).to eq(merchant_account)
    expect(order.reload.customer_account).to eq(customer.customer_accounts.first)
    expect(order_item.reload.account).to eq(merchant_account)
    expect(product.marketplace_listing).to be_visible
  end

  it "is idempotent" do
    customer = user("backfill.idempotent@example.com", "customer")

    expect do
      described_class.call
      described_class.call
    end.to change { customer.reload.customer_accounts.count }.by(1)
  end

  it "adds memberships for new supplier users when the merchant account already exists" do
    owner = user("backfill.existing.owner@example.com", "supplier")
    employee = user("backfill.existing.employee@example.com", "supplier")
    supplier = Supplier.create!(name: "Existing Account Supplier", default_lead_time_days: 7)
    SupplierUser.create!(supplier: supplier, user: owner)
    account = Account.create!(name: "Existing Account Supplier", account_type: "enterprise_merchant", creator: owner)
    account.account_memberships.create!(user: owner, role: "owner")
    MerchantProfile.create!(account: account, supplier: supplier, display_name: supplier.name)
    SupplierUser.create!(supplier: supplier, user: employee)

    described_class.call

    expect(account.account_memberships.find_by!(user: employee).role).to eq("employee")
  end

  it "promotes existing individual merchant accounts when legacy supplier users become multi-user" do
    owner = user("backfill.promote.owner@example.com", "supplier")
    employee = user("backfill.promote.employee@example.com", "supplier")
    supplier = Supplier.create!(name: "Promoted Legacy Supplier", default_lead_time_days: 7)
    SupplierUser.create!(supplier: supplier, user: owner)
    account = Account.create_with_owner!(
      creator: owner,
      name: supplier.name,
      account_type: "individual_merchant"
    )
    MerchantProfile.create!(account: account, supplier: supplier, display_name: supplier.name)
    SupplierUser.create!(supplier: supplier, user: employee)

    described_class.call

    expect(account.reload).to be_enterprise_merchant
    expect(account.account_memberships.find_by!(user: employee).role).to eq("employee")
  end
end

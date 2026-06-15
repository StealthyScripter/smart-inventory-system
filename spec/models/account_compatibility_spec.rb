require "rails_helper"

RSpec.describe "Supplier account compatibility", type: :model do
  def build_user(email, role: "supplier")
    User.create!(
      first_name: "Compat",
      last_name: "User",
      email: email,
      role: role,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "maps a supplier to its merchant account through the merchant profile" do
    supplier = Supplier.create!(name: "Mapped Supplier", default_lead_time_days: 7)
    owner = build_user("mapped.owner@example.com", role: "customer")
    account = Account.create_with_owner!(
      creator: owner,
      name: "Mapped Merchant",
      account_type: "enterprise_merchant"
    )

    MerchantProfile.create!(account: account, supplier: supplier, display_name: "Mapped Merchant")

    expect(supplier.merchant_account).to eq(account)
  end

  it "resolves an existing supplier user to a mapped account membership" do
    supplier = Supplier.create!(name: "Linked Supplier", default_lead_time_days: 7)
    merchant = build_user("linked.merchant@example.com")
    supplier_user = SupplierUser.create!(supplier: supplier, user: merchant)
    account = Account.create_with_owner!(
      creator: merchant,
      name: "Linked Account",
      account_type: "individual_merchant"
    )
    membership = account.account_memberships.find_by!(user: merchant)

    MerchantProfile.create!(account: account, supplier: supplier, display_name: "Linked Account")

    expect(supplier_user.account_membership).to eq(membership)
  end
end

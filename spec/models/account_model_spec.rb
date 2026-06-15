require "rails_helper"

RSpec.describe "Account model foundation", type: :model do
  def build_user(email)
    User.create!(
      first_name: "Account",
      last_name: "User",
      email: email,
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "validates supported account types and statuses" do
    account = Account.new(name: "Invalid Account", account_type: "supplier", status: "active")

    expect(account).not_to be_valid
    expect(account.errors[:account_type]).to be_present

    account.account_type = "customer"
    account.status = "disabled"

    expect(account).not_to be_valid
    expect(account.errors[:status]).to be_present
  end

  it "validates supported membership roles" do
    user = build_user("role.validation@example.com")
    account = Account.create!(name: "Role Validation", account_type: "enterprise_merchant")
    membership = account.account_memberships.new(user: user, role: "super_user")

    expect(membership).not_to be_valid
    expect(membership.errors[:role]).to be_present
  end

  it "creates an owner membership for the account creator" do
    creator = build_user("creator@example.com")

    account = Account.create_with_owner!(
      creator: creator,
      name: "Creator Shop",
      account_type: "enterprise_merchant"
    )

    membership = account.account_memberships.find_by!(user: creator)
    expect(account.creator).to eq(creator)
    expect(membership.role).to eq("owner")
    expect(membership).to be_owner_or_admin
  end

  it "defaults added enterprise members to employee" do
    creator = build_user("enterprise.owner@example.com")
    employee = build_user("enterprise.employee@example.com")
    account = Account.create_with_owner!(
      creator: creator,
      name: "Enterprise Shop",
      account_type: "enterprise_merchant"
    )

    membership = account.add_member!(employee)

    expect(membership.role).to eq("employee")
    expect(account.account_memberships.active.count).to eq(2)
  end

  it "allows enterprise merchant accounts to have multiple users" do
    first_user = build_user("multi.one@example.com")
    second_user = build_user("multi.two@example.com")
    account = Account.create!(name: "Multi User Shop", account_type: "enterprise_merchant")

    account.account_memberships.create!(user: first_user, role: "owner")
    account.account_memberships.create!(user: second_user, role: "inventory_manager")

    expect(account.users).to contain_exactly(first_user, second_user)
  end

  it "allows only one active managing membership for an individual merchant account" do
    owner = build_user("solo.owner@example.com")
    extra_user = build_user("solo.extra@example.com")
    account = Account.create_with_owner!(
      creator: owner,
      name: "Solo Shop",
      account_type: "individual_merchant"
    )

    membership = account.account_memberships.new(user: extra_user, role: "employee")

    expect(membership).not_to be_valid
    expect(membership.errors[:account]).to include("can only have one active membership for an individual merchant")
  end

  it "permits an inactive extra membership for individual merchant transition records" do
    owner = build_user("solo.active@example.com")
    extra_user = build_user("solo.inactive@example.com")
    account = Account.create_with_owner!(
      creator: owner,
      name: "Solo Transition Shop",
      account_type: "individual_merchant"
    )

    membership = account.account_memberships.create!(user: extra_user, role: "viewer", active: false)

    expect(membership).to be_persisted
    expect(account.account_memberships.active.count).to eq(1)
  end

  it "associates customer profiles only with customer accounts" do
    user = build_user("customer.profile@example.com")
    account = Account.create_with_owner!(creator: user, name: "Customer Account", account_type: "customer")

    profile = CustomerProfile.create!(account: account, user: user, display_name: "Customer")

    expect(account.customer_profile).to eq(profile)
    expect(user.customer_profile).to eq(profile)
  end

  it "rejects customer profiles for merchant accounts" do
    user = build_user("invalid.customer.profile@example.com")
    account = Account.create_with_owner!(
      creator: user,
      name: "Merchant Account",
      account_type: "enterprise_merchant"
    )

    profile = CustomerProfile.new(account: account, user: user)

    expect(profile).not_to be_valid
    expect(profile.errors[:account]).to include("must be a customer account")
  end

  it "associates merchant profiles only with merchant accounts" do
    owner = build_user("merchant.profile@example.com")
    account = Account.create_with_owner!(
      creator: owner,
      name: "Profile Merchant",
      account_type: "individual_merchant"
    )

    profile = MerchantProfile.create!(account: account, display_name: "Profile Merchant", slug: "Profile Merchant")

    expect(account.merchant_profile).to eq(profile)
    expect(profile.slug).to eq("profile-merchant")
  end

  it "rejects merchant profiles for customer accounts" do
    user = build_user("invalid.merchant.profile@example.com")
    account = Account.create_with_owner!(creator: user, name: "Customer Only", account_type: "customer")

    profile = MerchantProfile.new(account: account, display_name: "Not Merchant")

    expect(profile).not_to be_valid
    expect(profile.errors[:account]).to include("must be a merchant account")
  end
end

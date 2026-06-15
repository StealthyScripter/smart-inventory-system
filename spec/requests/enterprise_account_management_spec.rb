require "rails_helper"

RSpec.describe "Enterprise account management", type: :request do
  def build_user(email, role: "customer")
    create_authenticated_user(role: role, email: email)
  end

  def build_merchant_account(owner:, account_type: "enterprise_merchant")
    supplier = Supplier.create!(name: "#{account_type} Supplier", default_lead_time_days: 7)
    account = Account.create_with_owner!(creator: owner, name: "#{account_type} Account", account_type: account_type)
    MerchantProfile.create!(account: account, supplier: supplier, display_name: account.name)
    account
  end

  it "allows enterprise admins to update account and profile defaults" do
    owner = build_user("settings.owner@example.com")
    account = build_merchant_account(owner: owner)
    login_as(owner)

    patch merchant_account_settings_path, params: {
      account: { name: "Updated Enterprise" },
      merchant_profile: {
        display_name: "Updated Shop",
        description: "Updated profile",
        default_listing_status: "private",
        default_inventory_policy: "reserve_on_checkout",
        default_fulfillment_days: 5
      }
    }

    expect(response).to redirect_to(edit_merchant_account_settings_path)
    expect(account.reload.name).to eq("Updated Enterprise")
    expect(account.merchant_profile.reload.default_fulfillment_days).to eq(5)
  end

  it "allows enterprise admins to add existing users as employee members" do
    owner = build_user("member.owner@example.com")
    employee = build_user("member.employee@example.com")
    account = build_merchant_account(owner: owner)
    login_as(owner)

    post merchant_members_path, params: { account_membership: { email: employee.email } }

    membership = account.account_memberships.find_by!(user: employee)
    expect(response).to redirect_to(merchant_members_path)
    expect(membership.role).to eq("employee")
  end

  it "allows enterprise admins to promote and demote members" do
    owner = build_user("promote.owner@example.com")
    member = build_user("promote.member@example.com")
    account = build_merchant_account(owner: owner)
    membership = account.account_memberships.create!(user: member, role: "employee")
    login_as(owner)

    patch merchant_member_path(membership), params: { account_membership: { role: "inventory_manager" } }

    expect(response).to redirect_to(merchant_members_path)
    expect(membership.reload.role).to eq("inventory_manager")
  end

  it "blocks non-admin members from managing members" do
    owner = build_user("blocked.owner@example.com")
    member = build_user("blocked.member@example.com")
    account = build_merchant_account(owner: owner)
    account.account_memberships.create!(user: member, role: "employee")
    login_as(member)

    get merchant_members_path

    expect(response).to have_http_status(:forbidden)
  end

  it "prevents removal of the last owner or admin" do
    owner = build_user("last.owner@example.com")
    account = build_merchant_account(owner: owner)
    membership = account.account_memberships.find_by!(user: owner)
    login_as(owner)

    delete merchant_member_path(membership)

    expect(response).to redirect_to(merchant_members_path)
    expect(membership.reload).to be_active
  end

  it "blocks individual merchants from team management" do
    owner = build_user("individual.team@example.com")
    build_merchant_account(owner: owner, account_type: "individual_merchant")
    login_as(owner)

    get merchant_members_path

    expect(response).to have_http_status(:forbidden)
  end

  it "blocks disabled members from merchant tools" do
    owner = build_user("disabled.owner@example.com")
    member = build_user("disabled.member@example.com")
    account = build_merchant_account(owner: owner)
    membership = account.account_memberships.create!(user: member, role: "catalog_manager", active: false)
    login_as(member)

    get merchant_products_path
    expect(response).to have_http_status(:forbidden)

    login_as(owner)
    patch enable_merchant_member_path(membership)
    expect(membership.reload).to be_active
  end
end

require "rails_helper"

RSpec.describe AccountMembership, type: :model do
  def build_user(email)
    User.create!(
      first_name: "Permission",
      last_name: "User",
      email: email,
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  def membership_for(role, status: "active")
    user = build_user("#{role}.permissions@example.com")
    account = Account.create!(name: "#{role} Account", account_type: "enterprise_merchant", status: status)

    described_class.create!(account: account, user: user, role: role)
  end

  it "grants all account permissions to owners and admins" do
    owner = membership_for("owner")
    admin = membership_for("admin")

    expect(AccountMembership::ALL_PERMISSIONS).to all(satisfy { |permission| owner.has_permission?(permission) })
    expect(AccountMembership::ALL_PERMISSIONS).to all(satisfy { |permission| admin.has_permission?(permission) })
  end

  it "limits catalog managers to catalog and listing permissions" do
    membership = membership_for("catalog_manager")

    expect(membership).to have_permission(:manage_catalog)
    expect(membership).to have_permission(:publish_listings)
    expect(membership).not_to have_permission(:manage_members)
    expect(membership).not_to have_permission(:adjust_stock)
  end

  it "limits inventory managers to inventory permissions" do
    membership = membership_for("inventory_manager")

    expect(membership).to have_permission(:manage_inventory)
    expect(membership).to have_permission(:view_inventory)
    expect(membership).to have_permission(:adjust_stock)
    expect(membership).not_to have_permission(:publish_listings)
  end

  it "limits order managers to order fulfillment permissions" do
    membership = membership_for("order_manager")

    expect(membership).to have_permission(:view_orders)
    expect(membership).to have_permission(:manage_orders)
    expect(membership).to have_permission(:fulfill_orders)
    expect(membership).not_to have_permission(:manage_inventory)
  end

  it "limits service managers to services and bookings" do
    membership = membership_for("service_manager")

    expect(membership).to have_permission(:manage_services)
    expect(membership).to have_permission(:manage_bookings)
    expect(membership).not_to have_permission(:manage_roles)
  end

  it "keeps employees away from account administration" do
    membership = membership_for("employee")

    expect(membership).to have_permission(:view_inventory)
    expect(membership).to have_permission(:view_orders)
    expect(membership).not_to have_permission(:manage_account_settings)
    expect(membership).not_to have_permission(:manage_members)
  end

  it "denies permissions for suspended accounts" do
    membership = membership_for("owner", status: "suspended")

    expect(membership).not_to have_permission(:manage_catalog)
  end
end

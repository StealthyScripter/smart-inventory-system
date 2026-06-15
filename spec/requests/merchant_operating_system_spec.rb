require "rails_helper"

RSpec.describe "Merchant operating system dashboard", type: :request do
  def build_merchant(role:, account_type:, email:)
    user = create_authenticated_user(role: "customer", email: email)
    supplier = Supplier.create!(name: "#{email} Supplier", default_lead_time_days: 7)
    account = Account.create!(name: "#{email} Merchant", account_type: account_type)
    account.account_memberships.create!(user: user, role: role)
    MerchantProfile.create!(account: account, supplier: supplier, display_name: account.name)
    user
  end

  it "keeps individual merchants away from team management" do
    user = build_merchant(role: "owner", account_type: "individual_merchant", email: "individual.os@example.com")
    login_as(user)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Marketplace Listings")
    expect(response.body).to include("Local Inventory")
    expect(response.body).not_to include(">Team<")
  end

  it "shows team and settings tools to enterprise admins" do
    user = build_merchant(role: "admin", account_type: "enterprise_merchant", email: "enterprise.admin.os@example.com")
    login_as(user)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(">Team<")
    expect(response.body).to include(">Settings<")
  end

  it "shows only permitted tools to enterprise employees" do
    user = build_merchant(role: "employee", account_type: "enterprise_merchant", email: "enterprise.employee.os@example.com")
    login_as(user)

    get merchant_root_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Local Inventory")
    expect(response.body).to include(">Orders<")
    expect(response.body).not_to include("Marketplace Listings")
    expect(response.body).not_to include(">Team<")
    expect(response.body).not_to include(">Settings<")
  end
end

require "rails_helper"

RSpec.describe "Account onboarding", type: :request do
  def user_params(email)
    {
      email: email,
      first_name: "Onboard",
      last_name: "User",
      password: "password123",
      password_confirmation: "password123"
    }
  end

  it "redirects customer login to the catalog" do
    customer = create_authenticated_user(role: "customer", email: "login.customer@example.com")

    post customers_sign_in_path, params: { email: customer.email, password: "password123", login_context: "customer" }

    expect(response).to redirect_to(catalog_path)
  end

  it "redirects merchant login to the merchant dashboard" do
    supplier = Supplier.create!(name: "Login Merchant", default_lead_time_days: 7)
    merchant = create_authenticated_user(role: "customer", email: "login.merchant@example.com")
    account = Account.create_with_owner!(creator: merchant, name: "Login Merchant", account_type: "enterprise_merchant")
    MerchantProfile.create!(account: account, supplier: supplier, display_name: "Login Merchant")

    post merchants_sign_in_path, params: { email: merchant.email, password: "password123", login_context: "merchant" }

    expect(response).to redirect_to(merchant_root_path)
  end

  it "creates a customer account and profile during customer signup" do
    expect do
      post customers_sign_up_path, params: { user: user_params("signup.customer@example.com") }
    end.to change(Account.customers, :count).by(1)
      .and change(CustomerProfile, :count).by(1)

    user = User.find_by!(email: "signup.customer@example.com")
    account = user.customer_accounts.first

    expect(response).to redirect_to(catalog_path)
    expect(user).to be_customer
    expect(account.customer_profile.user).to eq(user)
  end

  it "creates an individual merchant account with one owner membership" do
    expect do
      post merchants_sign_up_path, params: {
        user: user_params("signup.individual@example.com"),
        merchant: { account_type: "individual_merchant", shop_name: "Individual Shop" }
      }
    end.to change(Account.individual_merchants, :count).by(1)
      .and change(MerchantProfile, :count).by(1)

    user = User.find_by!(email: "signup.individual@example.com")
    account = user.merchant_accounts.first

    expect(response).to redirect_to(merchant_root_path)
    expect(user).to be_supplier_user
    expect(account.account_memberships.active.count).to eq(1)
    expect(account.account_memberships.first.role).to eq("owner")
    expect(account.merchant_profile.supplier).to be_present
  end

  it "creates an enterprise merchant account with owner/admin-capable membership" do
    post merchants_sign_up_path, params: {
      user: user_params("signup.enterprise@example.com"),
      merchant: { account_type: "enterprise_merchant", shop_name: "Enterprise Shop" }
    }

    user = User.find_by!(email: "signup.enterprise@example.com")
    account = user.merchant_accounts.enterprise_merchants.first
    membership = account.account_memberships.find_by!(user: user)

    expect(response).to redirect_to(merchant_root_path)
    expect(account).to be_enterprise_merchant
    expect(membership.role).to eq("owner")
    expect(membership).to be_owner_or_admin
  end

  it "keeps customer-only users out of merchant onboarding-only areas" do
    customer = create_authenticated_user(role: "customer", email: "merchant.only.blocked@example.com")
    login_as(customer)

    get merchant_root_path

    expect(response).to have_http_status(:forbidden)
  end

  it "does not create a customer account during merchant signup" do
    post merchants_sign_up_path, params: {
      user: user_params("merchant.not.customer@example.com"),
      merchant: { account_type: "enterprise_merchant", shop_name: "Merchant Only Shop" }
    }

    user = User.find_by!(email: "merchant.not.customer@example.com")

    expect(user.customer_accounts).to be_empty
    expect(user.merchant_accounts).to be_present
  end
end

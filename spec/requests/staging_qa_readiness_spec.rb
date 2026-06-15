require "rails_helper"

RSpec.describe "Staging QA readiness", type: :request do
  before do
    DemoMarketplaceSeed.call
  end

  it "renders guest QA entry points" do
    get root_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Portland Cement 50kg")

    get services_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Interior Design Consultation")

    get merchant_storefront_path(Supplier.find_by!(name: "Oak City Hardware"))
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Oak City Hardware")
  end

  it "renders customer and merchant authentication QA entry points" do
    get customers_sign_in_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Sign in to your account")

    get customers_sign_up_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Customer")

    get merchants_sign_in_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Sign in to your account")

    get merchants_sign_up_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Merchant")
  end
end

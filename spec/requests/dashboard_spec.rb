require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create_authenticated_user }

  before do
    login_as(user)
  end

  describe "GET /dashboard" do
    it "returns http success" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "displays dashboard content" do
      get dashboard_path
      expect(response.body).to include("Dashboard")
      expect(response.body).to include("Inventory Value")
    end
  end

  describe "GET /" do
    it "returns http success for the public catalog root" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "renders catalog content" do
      get root_path
      expect(response.body).to include("Marketplace / Catalog")
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "keeps the public catalog available" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end

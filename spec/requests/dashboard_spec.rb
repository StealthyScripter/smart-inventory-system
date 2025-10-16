require 'rails_helper'

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
      expect(response.body).to include("Total Products")
    end
  end

  describe "GET /" do
    it "returns http success for root path" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to dashboard" do
      get root_path
      expect(response.body).to include("Dashboard")
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "redirects to login page" do
      get root_path
      expect(response).to redirect_to(login_path)
    end
  end
end

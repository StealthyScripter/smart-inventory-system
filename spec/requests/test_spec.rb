require 'rails_helper'

RSpec.describe "Tests", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/test/show"
      expect(response).to have_http_status(:success)
    end
  end

end

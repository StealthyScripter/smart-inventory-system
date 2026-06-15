require "rails_helper"

RSpec.describe "Production hardening", type: :request do
  it "serves the health check endpoint" do
    get rails_health_check_path

    expect(response).to have_http_status(:success)
  end

  it "sends a content security policy header" do
    get catalog_path

    expect(response.headers["Content-Security-Policy"]).to include("default-src 'self'")
    expect(response.headers["Content-Security-Policy"]).to include("object-src 'none'")
  end

  it "keeps test storage on the isolated test service" do
    expect(Rails.application.config.active_storage.service).to eq(:test)
  end
end

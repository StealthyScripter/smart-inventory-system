require "rails_helper"

RSpec.describe "Production hardening", type: :request do
  it "sends a content security policy header" do
    get catalog_path

    expect(response.headers["Content-Security-Policy"]).to include("default-src 'self'")
    expect(response.headers["Content-Security-Policy"]).to include("object-src 'none'")
  end
end

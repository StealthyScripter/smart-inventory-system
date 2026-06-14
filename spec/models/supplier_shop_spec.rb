require "rails_helper"

RSpec.describe Supplier, type: :model do
  it "normalizes shop slugs and validates shop status" do
    supplier = Supplier.create!(name: "Slug Shop", default_lead_time_days: 7, shop_slug: "Slug Shop", shop_status: "public")

    expect(supplier.shop_slug).to eq("slug-shop")
    expect(supplier).to be_public_shop

    supplier.shop_status = "unknown"
    expect(supplier).not_to be_valid
  end
end

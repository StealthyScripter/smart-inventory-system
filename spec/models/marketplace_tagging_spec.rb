require "rails_helper"

RSpec.describe "Marketplace tagging", type: :model do
  let(:category) { Category.create!(name: "Tagged Goods") }
  let(:supplier) { Supplier.create!(name: "Tagged Merchant", default_lead_time_days: 5) }

  it "assigns typed reusable tags from the backend tag list" do
    product = Product.create!(
      name: "Tagged Drill",
      sku: "TAGGED-DRILL",
      category: category,
      supplier: supplier,
      marketplace_tag_list: "category:Construction essentials, event:Father's Day, action:Recommended"
    )

    expect(product.tags.pluck(:context, :name)).to contain_exactly(
      ["category", "Construction essentials"],
      ["event", "Father's Day"],
      ["action", "Recommended"]
    )
  end

  it "shares the same tag across products, services, and merchants" do
    tag = Tag.create!(name: "Emergency ready", context: "condition")
    product = Product.create!(name: "Emergency Kit", sku: "EMERGENCY-KIT", category: category, supplier: supplier)
    service = ServiceListing.create!(
      supplier: supplier,
      name: "Emergency Repair",
      service_category: "Plumbing"
    )

    product.tags << tag
    service.tags << tag
    supplier.tags << tag

    expect(tag.taggings.map(&:taggable)).to contain_exactly(product, service, supplier)
  end
end

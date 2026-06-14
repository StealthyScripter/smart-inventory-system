require "rails_helper"

RSpec.describe RecommendationService do
  it "recommends public products in the same category" do
    category = Category.create!(name: "Recommendation")
    product = Product.create!(name: "Base", sku: "REC-BASE", category: category, marketplace_status: "public")
    recommended = Product.create!(name: "Match", sku: "REC-MATCH", category: category, marketplace_status: "public")
    Product.create!(name: "Hidden", sku: "REC-HIDDEN", category: category, marketplace_status: "draft")

    expect(described_class.new.product_recommendations(product)).to include(recommended)
  end
end

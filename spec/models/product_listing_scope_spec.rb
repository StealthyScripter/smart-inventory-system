require "rails_helper"

RSpec.describe Product, type: :model do
  let(:category) { Category.create!(name: "Listing Scope") }

  it "validates listing scope values" do
    product = Product.new(name: "Scoped", sku: "SCOPED", category: category, listing_scope: "external")

    expect(product).not_to be_valid
    expect(product.errors[:listing_scope]).to be_present
  end
end

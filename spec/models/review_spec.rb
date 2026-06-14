require "rails_helper"

RSpec.describe Review, type: :model do
  let(:category) { Category.create!(name: "Review Model") }
  let(:supplier) { Supplier.create!(name: "Review Model Supplier", default_lead_time_days: 7) }
  let(:customer) do
    User.create!(
      first_name: "Review",
      last_name: "Customer",
      email: "review.model@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let(:product) { Product.create!(name: "Review Model Product", sku: "REVIEW-MODEL", category: category, supplier: supplier, marketplace_status: "public") }
  let(:order) { Order.create!(user: customer, status: "delivered", total_amount: 5) }
  let(:order_item) do
    order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 5, total_amount: 5, fulfillment_status: "delivered")
  end

  it "requires ratings in bounds" do
    review = Review.new(user: customer, product: product, supplier: supplier, order_item: order_item, rating: 6)

    expect(review).not_to be_valid
    expect(review.errors[:rating]).to be_present
  end

  it "requires a delivered purchase" do
    order_item.update!(fulfillment_status: "shipped")
    review = Review.new(user: customer, product: product, supplier: supplier, order_item: order_item, rating: 5)

    expect(review).not_to be_valid
    expect(review.errors[:order_item]).to be_present
  end
end

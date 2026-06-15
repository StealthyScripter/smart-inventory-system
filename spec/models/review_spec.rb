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
  let(:service_listing) { ServiceListing.create!(supplier: supplier, name: "Review Model Service", service_category: "Cleaning", status: "public") }
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

  it "requires a completed service booking for service reviews" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "scheduled")
    booking.service_booking_items.create!(service_listing: service_listing)
    review = Review.new(user: customer, supplier: supplier, service_listing: service_listing, rating: 5)

    expect(review).not_to be_valid
    expect(review.errors[:service_listing]).to include("must be a completed booking by this customer")

    booking.update!(status: "completed")
    expect(review).to be_valid
  end

  it "prevents duplicate service reviews" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "completed")
    booking.service_booking_items.create!(service_listing: service_listing)
    Review.create!(user: customer, supplier: supplier, service_listing: service_listing, rating: 5)
    duplicate = Review.new(user: customer, supplier: supplier, service_listing: service_listing, rating: 4)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:service_listing_id]).to be_present
  end
end

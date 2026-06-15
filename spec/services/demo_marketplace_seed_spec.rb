require "rails_helper"

RSpec.describe DemoMarketplaceSeed do
  it "creates realistic marketplace demo data idempotently" do
    described_class.call

    expect(Supplier.find_by(name: "Oak City Hardware")).to be_present
    expect(Product.find_by(sku: "DEMO-CEMENT-50")).to be_publicly_listed
    expect(Product.find_by(sku: "DEMO-CEMENT-50").marketplace_listing).to be_visible
    expect(ServiceListing.find_by(name: "Interior Design Consultation")).to be_present
    expect(Order.find_by(order_number: "DEMO-COMPLETE-001")).to be_present
    expect(ServiceBooking.find_by(booking_number: "DEMO-BOOKING-001")).to be_present
    expect(Review.find_by(body: "Reliable demo delivery and product quality.")).to be_present
    expect(User.find_by(email: "buyer.contractor@example.com").customer_accounts).to be_present
    expect(Supplier.find_by(name: "Triangle Construction Supply").merchant_account).to be_individual_merchant
    expect(Supplier.find_by(name: "Oak City Hardware").merchant_account).to be_enterprise_merchant
    expect(User.find_by(email: "merchant.hardware.employee@example.com").account_memberships.first.role).to eq("employee")

    counts = demo_counts
    described_class.call

    expect(demo_counts).to eq(counts)
  end

  def demo_counts
    {
      suppliers: Supplier.where(shop_status: "public").count,
      products: Product.where("sku LIKE ?", "DEMO-%").count,
      services: ServiceListing.where(name: [
        "Interior Design Consultation",
        "Emergency Plumbing Repair",
        "Electrical Installation",
        "AC Repair Visit",
        "Exterior Painting Crew"
      ]).count,
      orders: Order.where("order_number LIKE ?", "DEMO-%").count,
      bookings: ServiceBooking.where("booking_number LIKE ?", "DEMO-%").count
    }
  end
end

require "rails_helper"

RSpec.describe ServiceBooking, type: :model do
  let(:customer) do
    User.create!(
      first_name: "Booking",
      last_name: "Customer",
      email: "booking.model@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let(:supplier) { Supplier.create!(name: "Booking Model Supplier", default_lead_time_days: 7) }

  it "assigns booking numbers and enforces transitions" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier)

    expect(booking.booking_number).to start_with("SB-")
    booking.transition_to!("accepted")
    expect(booking.status).to eq("accepted")
    expect { booking.transition_to!("completed") }.to raise_error(ArgumentError)
  end
end

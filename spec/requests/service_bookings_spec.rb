require "rails_helper"

RSpec.describe "Service bookings", type: :request do
  let!(:supplier) { Supplier.create!(name: "Booking Provider", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "booking.merchant@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "booking.customer@example.com") }
  let!(:service) { ServiceListing.create!(supplier: supplier, name: "Bookable Cleaning", service_category: "Cleaning", status: "public", starting_price: 50) }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "lets customers request a service booking" do
    login_as(customer)

    expect do
      post service_bookings_path, params: {
        service_listing_id: service.id,
        scheduled_date: Date.current + 1.day,
        scheduled_time: "10:00",
        duration_minutes: 120,
        notes: "Bring supplies"
      }
    end.to change(ServiceBooking, :count).by(1)
      .and change { merchant.notifications.count }.by(1)

    booking = customer.service_bookings.last
    expect(booking.status).to eq("requested")
    expect(booking.service_listings).to include(service)
  end

  it "lets merchants manage supplier bookings" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "requested")
    booking.service_booking_items.create!(service_listing: service, quoted_price: 50)
    login_as(merchant)

    patch merchant_service_booking_path(booking), params: {
      status: "accepted",
      scheduled_date: Date.current + 2.days,
      scheduled_time: "09:00",
      duration_minutes: 60
    }

    expect(response).to redirect_to(merchant_service_bookings_path)
    expect(booking.reload.status).to eq("accepted")
    expect(customer.notifications.last.title).to eq("Booking Accepted")
  end

  it "blocks merchants from another supplier's bookings" do
    other_supplier = Supplier.create!(name: "Other Booking", default_lead_time_days: 7)
    booking = ServiceBooking.create!(user: customer, supplier: other_supplier, status: "requested")
    login_as(merchant)

    patch merchant_service_booking_path(booking), params: { status: "accepted" }

    expect(response).to have_http_status(:not_found)
  end

  it "lets customers cancel their own requested bookings" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "requested")
    login_as(customer)

    patch customer_service_booking_path(booking)

    expect(booking.reload.status).to eq("cancelled")
  end

  it "redirects guests who try to book" do
    post service_bookings_path, params: { service_listing_id: service.id }

    expect(response).to redirect_to(login_path)
  end
end

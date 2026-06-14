class ServiceBookingsController < ApplicationController
  before_action :require_customer_access

  def create
    service = ServiceListing.publicly_listed.find(params[:service_listing_id])
    booking = current_user.service_bookings.create!(
      supplier: service.supplier,
      scheduled_date: params[:scheduled_date],
      scheduled_time: params[:scheduled_time],
      duration_minutes: params[:duration_minutes],
      notes: params[:notes]
    )
    booking.service_booking_items.create!(service_listing: service, quoted_price: service.starting_price)
    NotificationService.notify_supplier_users!(
      service.supplier,
      event_type: "booking.requested",
      title: "New booking request",
      body: "#{current_user.full_name} requested #{service.name}"
    )

    redirect_to customer_service_bookings_path, notice: "Booking was requested."
  end

  private

  def require_customer_access
    return if customer?

    redirect_to login_path, alert: "Please log in as a customer to book services."
  end
end

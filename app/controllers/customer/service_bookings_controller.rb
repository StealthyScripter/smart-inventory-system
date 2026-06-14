module Customer
  class ServiceBookingsController < BaseController
    def index
      @bookings = current_user.service_bookings.includes(:supplier, :service_listings).order(created_at: :desc)
    end

    def update
      booking = current_user.service_bookings.find(params[:id])
      booking.transition_to!("cancelled")
      NotificationService.notify_supplier_users!(
        booking.supplier,
        event_type: "booking.cancelled",
        title: "Booking cancelled",
        body: "#{booking.booking_number} was cancelled by the customer."
      )

      redirect_to customer_service_bookings_path, notice: "Booking was cancelled."
    rescue ArgumentError
      redirect_to customer_service_bookings_path, alert: "Booking cannot be cancelled."
    end
  end
end

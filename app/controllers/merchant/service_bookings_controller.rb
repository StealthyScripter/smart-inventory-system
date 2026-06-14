module Merchant
  class ServiceBookingsController < BaseController
    def index
      @bookings = ServiceBooking.includes(:user, :service_listings).where(supplier: merchant_suppliers).order(created_at: :desc)
    end

    def update
      booking = ServiceBooking.where(supplier: merchant_suppliers).find(params[:id])
      booking.assign_attributes(booking_params)
      booking.transition_to!(params[:status])
      Notification.create!(
        user: booking.user,
        event_type: "booking.#{booking.status}",
        title: "Booking #{booking.status.titleize}",
        body: "#{booking.booking_number} is now #{booking.status.titleize}."
      )
      NotificationEmailJob.perform_later("BookingMailer", booking.status, booking) if %w[accepted completed].include?(booking.status)

      redirect_to merchant_service_bookings_path, notice: "Booking was updated."
    rescue ArgumentError, ActiveRecord::RecordInvalid
      redirect_to merchant_service_bookings_path, alert: "Booking could not be updated."
    end

    private

    def booking_params
      params.permit(:scheduled_date, :scheduled_time, :duration_minutes, :notes)
    end
  end
end

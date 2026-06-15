module Merchant
  class ServiceBookingsController < BaseController
    before_action -> { require_merchant_permission(:manage_bookings) }

    def index
      @bookings = merchant_bookings.includes(:user, :service_listings).order(created_at: :desc)
      @booking_queue = @bookings.where(status: ["requested", "accepted"])
      @upcoming_jobs = @bookings.where(status: ["scheduled", "in_progress"]).where("scheduled_date >= ?", Date.current).order(:scheduled_date, :scheduled_time)
      @calendar_bookings = @bookings.where.not(scheduled_date: nil).group_by(&:scheduled_date)
    end

    def update
      booking = merchant_bookings.find(params[:id])
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

    def estimate
      booking = merchant_bookings.includes(:user, :supplier, service_booking_items: :service_listing).find(params[:id])
      lines = [
        "Customer: #{booking.user.full_name}",
        "Provider: #{booking.supplier.name}",
        "Status: #{booking.status.titleize}",
        "Schedule: #{[booking.scheduled_date, booking.scheduled_time&.strftime('%H:%M')].compact.join(' ')}"
      ] + booking.service_booking_items.map do |item|
        "#{item.service_listing.name} - #{helpers.currency((item.quoted_price || item.service_listing.starting_price).to_f)}"
      end
      send_data SimplePdfRenderer.render("Service Estimate #{booking.booking_number}", lines),
                filename: "#{booking.booking_number}-estimate.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    def booking_params
      params.permit(:scheduled_date, :scheduled_time, :duration_minutes, :notes)
    end

    def merchant_bookings
      supplier_bookings = ServiceBooking.where(supplier: merchant_suppliers)
      return supplier_bookings unless current_merchant_account

      ServiceBooking.where(account: current_merchant_account).or(supplier_bookings)
    end
  end
end

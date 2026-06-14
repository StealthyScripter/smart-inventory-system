class BookingMailer < ApplicationMailer
  def accepted(booking)
    @booking = booking
    mail(to: booking.user.email, subject: "Booking #{booking.booking_number} accepted")
  end

  def completed(booking)
    @booking = booking
    mail(to: booking.user.email, subject: "Booking #{booking.booking_number} completed")
  end
end

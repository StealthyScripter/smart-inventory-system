module Customer
  class ProfilesController < BaseController
    def show
      @orders_count = current_user.orders.count
      @bookings_count = ServiceBooking.where(user: current_user).count
      @unread_notifications_count = current_user.notifications.unread.count
    end
  end
end

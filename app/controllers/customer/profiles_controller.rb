module Customer
  class ProfilesController < BaseController
    def show
      @orders = current_user.orders.order(created_at: :desc).limit(5)
      @bookings = current_user.service_bookings.includes(:supplier, :service_listings).order(created_at: :desc).limit(5)
      @unread_notifications = current_user.notifications.unread.count
      @conversations = current_user.customer_conversations.order(updated_at: :desc).limit(5)
      @customer_account = current_customer_account
    end
  end
end

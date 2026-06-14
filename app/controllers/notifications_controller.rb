class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read_at: Time.current)

    redirect_to notifications_path, notice: "Notification was marked as read."
  end
end

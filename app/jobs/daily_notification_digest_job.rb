class DailyNotificationDigestJob < ApplicationJob
  queue_as :notifications

  retry_on StandardError, wait: 10.minutes, attempts: 3

  def perform(user = nil)
    users = user ? User.where(id: user.id) : User.joins(:notifications).merge(Notification.unread).distinct
    users.find_each do |recipient|
      next if recipient.notifications.unread.empty?

      NotificationDigestMailer.daily(recipient).deliver_now
    end
  end
end

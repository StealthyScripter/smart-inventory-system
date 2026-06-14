class NotificationDigestMailer < ApplicationMailer
  def daily(user)
    @user = user
    @notifications = user.notifications.unread.order(created_at: :desc).limit(20)
    mail(to: user.email, subject: "Your Smart Inventory daily digest")
  end
end

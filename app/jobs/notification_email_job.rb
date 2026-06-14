class NotificationEmailJob < ApplicationJob
  queue_as :default

  def perform(mailer_name, action_name, record)
    mailer_name.constantize.public_send(action_name, record).deliver_now
  end
end

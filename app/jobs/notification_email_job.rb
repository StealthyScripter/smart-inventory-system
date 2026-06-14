class NotificationEmailJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: 5.minutes, attempts: 3

  def perform(mailer_name, action_name, record)
    mailer_name.constantize.public_send(action_name, record).deliver_now
  end
end

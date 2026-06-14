class MessageMailer < ApplicationMailer
  def created(message)
    @message = message
    recipients = if message.sender == message.conversation.customer
      message.conversation.supplier.users.pluck(:email)
    else
      [message.conversation.customer.email]
    end
    mail(to: recipients, subject: "New message: #{message.conversation.subject}")
  end
end

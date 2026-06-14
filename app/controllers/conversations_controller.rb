class ConversationsController < ApplicationController
  before_action :set_conversation

  def show
    @conversation.messages.where.not(sender: current_user).unread.update_all(read_at: Time.current)
    @message = Message.new
  end

  def create
    message = @conversation.messages.create!(sender: current_user, body: params.require(:message).permit(:body)[:body])
    notify_recipients!(message)
    NotificationEmailJob.perform_later("MessageMailer", "created", message)

    redirect_to conversation_path(@conversation), notice: "Message sent."
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
    return if @conversation.participant?(current_user)

    render plain: "You don't have permission to access this conversation.", status: :forbidden
  end

  def notify_recipients!(message)
    if current_user == @conversation.customer
      NotificationService.notify_supplier_users!(
        @conversation.supplier,
        event_type: "message.created",
        title: "New message",
        body: message.body
      )
    else
      Notification.create!(user: @conversation.customer, event_type: "message.created", title: "New message", body: message.body)
    end
  end
end

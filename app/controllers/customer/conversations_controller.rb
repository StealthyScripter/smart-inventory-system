module Customer
  class ConversationsController < BaseController
    def index
      @conversations = current_user.customer_conversations.includes(:supplier, :messages).order(updated_at: :desc)
    end
  end
end

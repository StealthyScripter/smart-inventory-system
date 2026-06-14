module Merchant
  class ConversationsController < BaseController
    def index
      @conversations = Conversation.includes(:customer, :messages)
                                   .where(supplier: merchant_suppliers)
                                   .order(updated_at: :desc)
    end
  end
end

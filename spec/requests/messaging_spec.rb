require "rails_helper"

RSpec.describe "Messaging", type: :request do
  let!(:supplier) { Supplier.create!(name: "Message Merchant", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "message.merchant@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "message.customer@example.com") }
  let!(:other_customer) { create_authenticated_user(role: "customer", email: "message.other@example.com") }
  let!(:conversation) { Conversation.create!(customer: customer, supplier: supplier, subject: "Order question") }

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "lets customers see only their conversations" do
    other_conversation = Conversation.create!(customer: other_customer, supplier: supplier, subject: "Secret")
    login_as(customer)

    get customer_conversations_path

    expect(response.body).to include(conversation.subject)
    expect(response.body).not_to include(other_conversation.subject)
  end

  it "blocks unauthorized conversation access" do
    login_as(other_customer)

    get conversation_path(conversation)

    expect(response).to have_http_status(:forbidden)
  end

  it "lets participants send scoped messages and notifies recipients" do
    login_as(customer)

    expect do
      post conversation_path(conversation), params: { message: { body: "Hello" } }
    end.to change(Message, :count).by(1)
      .and change { merchant.notifications.count }.by(1)

    expect(conversation.messages.last.sender).to eq(customer)
  end

  it "marks received messages read when opening a conversation" do
    message = conversation.messages.create!(sender: merchant, body: "Reply")
    login_as(customer)

    get conversation_path(conversation)

    expect(message.reload.read_at).to be_present
  end
end

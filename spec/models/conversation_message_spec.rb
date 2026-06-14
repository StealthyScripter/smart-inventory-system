require "rails_helper"

RSpec.describe Message, type: :model do
  it "requires the sender to participate in the conversation" do
    supplier = Supplier.create!(name: "Message Model Supplier", default_lead_time_days: 7)
    customer = User.create!(first_name: "Message", last_name: "Customer", email: "message.model.customer@example.com", role: "customer", password: "password123", password_confirmation: "password123")
    outsider = User.create!(first_name: "Message", last_name: "Outsider", email: "message.model.outsider@example.com", role: "customer", password: "password123", password_confirmation: "password123")
    conversation = Conversation.create!(customer: customer, supplier: supplier, subject: "Scoped")

    message = Message.new(conversation: conversation, sender: outsider, body: "Nope")

    expect(message).not_to be_valid
    expect(message.errors[:sender]).to be_present
  end
end

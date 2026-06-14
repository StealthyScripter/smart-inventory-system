require "rails_helper"

RSpec.describe "Notification mailers", type: :mailer do
  let!(:category) { Category.create!(name: "Mailer Hardware") }
  let!(:supplier) { Supplier.create!(name: "Mailer Merchant", default_lead_time_days: 7) }
  let!(:merchant) { create_user(role: "supplier", email: "mailer.merchant@example.com") }
  let!(:customer) { create_user(role: "customer", email: "mailer.customer@example.com") }
  let!(:product) do
    Product.create!(name: "Mailer Bolt", sku: "MAILER-BOLT", category: category, supplier: supplier, marketplace_status: "public")
  end
  let!(:order) { Order.create!(user: customer, status: "shipped", total_amount: 12) }
  let!(:order_item) do
    order.order_items.create!(
      product: product,
      supplier: supplier,
      quantity: 1,
      unit_price: 12,
      total_amount: 12,
      fulfillment_status: "delivered"
    )
  end

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "renders order status email" do
    mail = OrderMailer.shipped(order)

    expect(mail.to).to contain_exactly(customer.email)
    expect(mail.subject).to include(order.order_number, "shipped")
    expect(mail.body.encoded).to include(order.order_number)
  end

  it "renders booking lifecycle email" do
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "accepted")

    mail = BookingMailer.accepted(booking)

    expect(mail.to).to contain_exactly(customer.email)
    expect(mail.subject).to include(booking.booking_number, "accepted")
    expect(mail.body.encoded).to include(booking.booking_number)
  end

  it "renders review notification email for supplier users" do
    review = Review.create!(user: customer, product: product, supplier: supplier, order_item: order_item, rating: 5)

    mail = ReviewMailer.created(review)

    expect(mail.to).to contain_exactly(merchant.email)
    expect(mail.subject).to eq("New review received")
    expect(mail.body.encoded).to include("5/5", product.name)
  end

  it "renders message notification email for the other participant" do
    conversation = Conversation.create!(customer: customer, supplier: supplier, subject: "Delivery question")
    message = conversation.messages.create!(sender: customer, body: "Can you confirm timing?")

    mail = MessageMailer.created(message)

    expect(mail.to).to contain_exactly(merchant.email)
    expect(mail.subject).to include(conversation.subject)
    expect(mail.body.encoded).to include(message.body)
  end

  def create_user(attributes = {})
    User.create!(
      {
        first_name: "Mailer",
        last_name: "User",
        email: "mailer#{rand(1000..9999)}@example.com",
        role: "customer",
        password: "password123",
        password_confirmation: "password123"
      }.merge(attributes)
    )
  end
end

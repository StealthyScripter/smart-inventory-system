require "rails_helper"

RSpec.describe "Order lifecycle", type: :model do
  let(:customer) do
    User.create!(
      first_name: "Order",
      last_name: "Customer",
      email: "order.lifecycle@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "allows valid order status transitions" do
    order = Order.create!(user: customer, status: "pending", total_amount: 1)

    order.transition_to!("confirmed")

    expect(order.status).to eq("confirmed")
  end

  it "rejects invalid order status transitions" do
    order = Order.create!(user: customer, status: "pending", total_amount: 1)

    expect { order.transition_to!("shipped") }.to raise_error(ArgumentError)
  end
end

require "rails_helper"

RSpec.describe "Analytics insights", type: :request do
  it "shows admin platform analytics only to management users" do
    admin = create_authenticated_user(role: "admin", email: "analytics.admin@example.com")
    customer = create_authenticated_user(role: "customer", email: "analytics.customer@example.com")

    login_as(admin)
    get admin_analytics_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Merchant Count")

    login_as(customer)
    get admin_analytics_path
    expect(response).to redirect_to(root_path)
  end

  it "shows expanded customer analytics" do
    customer = create_authenticated_user(role: "customer", email: "analytics.customer2@example.com")
    Order.create!(user: customer, status: "pending", total_amount: 7)
    Notification.create!(user: customer, event_type: "test", title: "Unread")
    login_as(customer)

    get customer_analytics_path

    expect(response.body).to include("$7.00")
    expect(response.body).to include("Unread Notifications")
  end
end

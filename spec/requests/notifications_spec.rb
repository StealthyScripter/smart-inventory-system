require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let!(:user) { create_authenticated_user(role: "customer", email: "notify.customer@example.com") }

  it "lists current user's notifications and marks them read" do
    notification = Notification.create!(user: user, event_type: "test", title: "Hello", body: "Message")
    login_as(user)

    get notifications_path
    expect(response.body).to include("Hello")
    expect(response.body).to include("Unread")

    patch notification_path(notification)
    expect(notification.reload.read_at).to be_present
  end

  it "does not expose another user's notification" do
    other = create_authenticated_user(role: "customer", email: "notify.other@example.com")
    notification = Notification.create!(user: other, event_type: "test", title: "Secret")
    login_as(user)

    patch notification_path(notification)

    expect(response).to have_http_status(:not_found)
  end

  it "notifies merchant users when reviews are created" do
    category = Category.create!(name: "Notify")
    supplier = Supplier.create!(name: "Notify Merchant", default_lead_time_days: 7)
    merchant = create_authenticated_user(role: "supplier", email: "notify.merchant@example.com")
    SupplierUser.create!(supplier: supplier, user: merchant)
    product = Product.create!(name: "Notify Product", sku: "NOTIFY-PRODUCT", category: category, supplier: supplier)
    order = Order.create!(user: user, status: "delivered", total_amount: 1)
    item = order.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 1, total_amount: 1, fulfillment_status: "delivered")
    login_as(user)

    expect do
      post reviews_path, params: { order_item_id: item.id, order_id: order.id, review: { rating: 5, body: "Great" } }
    end.to change { merchant.notifications.count }.by(1)
  end
end

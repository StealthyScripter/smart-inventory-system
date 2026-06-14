require "rails_helper"

RSpec.describe "Real-world readiness", type: :request do
  let!(:category) { Category.create!(name: "Request Ready Category") }
  let!(:supplier) { Supplier.create!(name: "Request Ready Supplier", default_lead_time_days: 7) }
  let!(:merchant) { create_authenticated_user(role: "supplier", email: "ready.merchant@example.com") }
  let!(:admin) { create_authenticated_user(role: "admin", email: "ready.admin@example.com") }
  let!(:customer) { create_authenticated_user(role: "customer", email: "ready.customer@example.com") }
  let!(:product) { Product.create!(name: "Request Ready Product", sku: "READY-PRODUCT", category: category, supplier: supplier, marketplace_status: "public") }
  let!(:order) do
    Order.create!(user: customer, status: "delivered", total_amount: 12).tap do |record|
      record.order_items.create!(product: product, supplier: supplier, quantity: 1, unit_price: 12, total_amount: 12, fulfillment_status: "delivered")
    end
  end

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
  end

  it "renders product barcode and QR code SVGs" do
    login_as(admin)

    get barcode_product_path(product)
    expect(response.media_type).to eq("image/svg+xml")
    expect(response.body).to include("<svg")

    get qr_code_product_path(product)
    expect(response.media_type).to eq("image/svg+xml")
    expect(response.body).to include("<svg")
  end

  it "generates customer order PDF receipts" do
    login_as(customer)

    get customer_order_path(order, format: :pdf)

    expect(response.media_type).to eq("application/pdf")
    expect(response.body).to start_with("%PDF-1.4")
  end

  it "generates merchant service estimate PDFs" do
    service = ServiceListing.create!(supplier: supplier, name: "Ready Estimate Service", service_category: "Painting", status: "public", starting_price: 80)
    booking = ServiceBooking.create!(user: customer, supplier: supplier, status: "scheduled", scheduled_date: Date.current)
    ServiceBookingItem.create!(service_booking: booking, service_listing: service, quoted_price: 80)
    login_as(merchant)

    get estimate_merchant_service_booking_path(booking)

    expect(response.media_type).to eq("application/pdf")
    expect(response.body).to start_with("%PDF-1.4")
  end

  it "exports merchant analytics as CSV" do
    login_as(merchant)

    get merchant_analytics_path(format: :csv)

    expect(response.media_type).to eq("text/csv")
    expect(response.body).to include("metric,value", "sales_total")
  end

  it "soft deletes and restores marketplace records through governance actions" do
    login_as(admin)

    post admin_moderation_actions_path, params: {
      moderation_action: {
        moderatable_type: "Product",
        moderatable_id: product.id,
        action_name: "soft_delete"
      }
    }

    expect(product.reload).to be_discarded
    expect(product.marketplace_status).to eq("archived")

    post admin_moderation_actions_path, params: {
      moderation_action: {
        moderatable_type: "Product",
        moderatable_id: product.id,
        action_name: "restore"
      }
    }

    expect(product.reload).not_to be_discarded
    expect(product.marketplace_status).to eq("public")
  end
end

require "rails_helper"

RSpec.describe "Moderation governance", type: :model do
  let!(:admin) { create_user(role: "admin", email: "model.admin@example.com") }
  let!(:customer) { create_user(role: "customer", email: "model.customer@example.com") }
  let!(:category) { Category.create!(name: "Moderation Model Category") }
  let!(:supplier) { Supplier.create!(name: "Moderation Model Merchant", default_lead_time_days: 7) }
  let!(:product) { Product.create!(name: "Moderation Model Product", sku: "MOD-MODEL", category: category, supplier: supplier) }

  it "validates report statuses" do
    report = Report.new(reporter: customer, reportable: product, reason: "Unsafe", status: "invalid")

    expect(report).not_to be_valid
  end

  it "validates moderation action names" do
    action = ModerationAction.new(actor: admin, moderatable: product, action_name: "unknown")

    expect(action).not_to be_valid
  end

  def create_user(attributes = {})
    User.create!(
      {
        first_name: "Moderation",
        last_name: "User",
        email: "moderation#{rand(1000..9999)}@example.com",
        role: "customer",
        password: "password123",
        password_confirmation: "password123"
      }.merge(attributes)
    )
  end
end

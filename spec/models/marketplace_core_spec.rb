require "rails_helper"

RSpec.describe "Marketplace core models", type: :model do
  let(:category) { Category.create!(name: "Electrical") }
  let(:supplier) { Supplier.create!(name: "Merchant Supply", default_lead_time_days: 7) }
  let(:supplier_user) do
    User.create!(
      first_name: "Merchant",
      last_name: "User",
      email: "merchant.user@example.com",
      role: "supplier",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  it "connects supplier-role users to supplier organizations" do
    supplier_user_record = SupplierUser.create!(supplier: supplier, user: supplier_user)

    expect(supplier.supplier_users).to include(supplier_user_record)
    expect(supplier.users).to include(supplier_user)
    expect(supplier_user.suppliers).to include(supplier)
  end

  it "rejects supplier ownership links for non-supplier users" do
    customer = User.create!(
      first_name: "Customer",
      last_name: "User",
      email: "customer.link@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )

    supplier_user_record = SupplierUser.new(supplier: supplier, user: customer)

    expect(supplier_user_record).not_to be_valid
    expect(supplier_user_record.errors[:user]).to be_present
  end

  it "scopes public marketplace listings separately from inventory products" do
    public_product = Product.create!(
      name: "Public Relay",
      sku: "PUBLIC-RELAY",
      category: category,
      supplier: supplier,
      marketplace_status: "public"
    )
    Product.create!(
      name: "Draft Relay",
      sku: "DRAFT-RELAY",
      category: category,
      supplier: supplier,
      marketplace_status: "draft"
    )

    expect(Product.publicly_listed).to contain_exactly(public_product)
  end

  it "validates marketplace status values" do
    product = Product.new(name: "Invalid Status", sku: "BAD-STATUS", category: category, marketplace_status: "listed")

    expect(product).not_to be_valid
    expect(product.errors[:marketplace_status]).to be_present
  end
end

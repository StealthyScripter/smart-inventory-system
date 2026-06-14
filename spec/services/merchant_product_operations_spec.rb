require "rails_helper"

RSpec.describe MerchantProductOperations do
  let!(:category) { Category.create!(name: "Ops Category") }
  let!(:supplier) { Supplier.create!(name: "Ops Merchant", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Other Ops Merchant", default_lead_time_days: 7) }
  let!(:merchant) { create_user(role: "supplier", email: "ops.merchant@example.com") }
  let!(:location) { Location.create!(name: "Ops Warehouse") }
  let!(:product) do
    Product.create!(
      name: "Ops Bolt",
      sku: "OPS-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "draft",
      listing_scope: "both"
    )
  end
  let!(:other_product) do
    Product.create!(
      name: "Other Ops Bolt",
      sku: "OTHER-OPS-BOLT",
      category: category,
      supplier: other_supplier,
      marketplace_status: "draft"
    )
  end

  before do
    SupplierUser.create!(supplier: supplier, user: merchant)
    product.stock_levels.create!(location: location, current_quantity: 5, reserved_quantity: 0)
  end

  it "bulk updates only products owned by the merchant supplier" do
    count = described_class.new(merchant.suppliers, actor: merchant).bulk_update!(
      product_ids: [product.id, other_product.id],
      marketplace_status: "public"
    )

    expect(count).to eq(1)
    expect(product.reload.marketplace_status).to eq("public")
    expect(other_product.reload.marketplace_status).to eq("draft")
  end

  it "exports merchant products as CSV" do
    csv = described_class.new(merchant.suppliers, actor: merchant).export_csv

    expect(csv).to include("sku,name,description")
    expect(csv).to include(product.sku)
    expect(csv).not_to include(other_product.sku)
  end

  it "imports merchant-scoped products from CSV" do
    csv = StringIO.new(<<~CSV)
      sku,name,description,category,supplier,unit_cost,selling_price,reorder_point,lead_time_days,marketplace_status,listing_scope,search_tags
      OPS-NEW,Imported Product,Imported,Ops Category,Ops Merchant,1.00,2.00,4,7,public,both,imported
    CSV

    result = described_class.new(merchant.suppliers, actor: merchant).import_csv(csv)

    imported = Product.find_by!(sku: "OPS-NEW")
    expect(result).to eq(created: 1, updated: 0)
    expect(imported.supplier).to eq(supplier)
    expect(imported).to be_publicly_listed
  end

  it "rejects CSV imports with invalid headers" do
    csv = StringIO.new(<<~CSV)
      sku,name,supplier
      OPS-BAD,Bad Product,Ops Merchant
    CSV

    expect do
      described_class.new(merchant.suppliers, actor: merchant).import_csv(csv)
    end.to raise_error(MerchantProductOperations::CSVImportError)
  end

  it "rejects malformed CSV rows" do
    csv = StringIO.new(<<~CSV)
      sku,name,description,category,supplier,unit_cost,selling_price,reorder_point,lead_time_days,marketplace_status,listing_scope,search_tags
      OPS-BAD,"Bad Product,Imported,Ops Category,Ops Merchant,1.00,2.00,4,7,public,both,imported
    CSV

    expect do
      described_class.new(merchant.suppliers, actor: merchant).import_csv(csv)
    end.to raise_error(MerchantProductOperations::CSVImportError)
  end

  it "duplicates owned products as draft copies" do
    duplicate = described_class.new(merchant.suppliers, actor: merchant).duplicate!(product)

    expect(duplicate.sku).to eq("OPS-BOLT-COPY")
    expect(duplicate.marketplace_status).to eq("draft")
    expect(duplicate.stock_levels.first.current_quantity).to eq(0)
  end

  def create_user(attributes = {})
    User.create!(
      {
        first_name: "Ops",
        last_name: "User",
        email: "ops#{rand(1000..9999)}@example.com",
        role: "supplier",
        password: "password123",
        password_confirmation: "password123"
      }.merge(attributes)
    )
  end
end

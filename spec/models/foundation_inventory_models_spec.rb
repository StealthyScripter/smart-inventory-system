require "rails_helper"

RSpec.describe "Foundation inventory models", type: :model do
  let(:category) { Category.create!(name: "Industrial Parts") }
  let(:supplier) { Supplier.create!(name: "Supply Co", default_lead_time_days: 5) }
  let(:location) { Location.create!(name: "Main Warehouse") }
  let(:product) do
    Product.create!(
      name: "Bearing",
      sku: "BEARING-001",
      category: category,
      supplier: supplier,
      reorder_point: 10,
      lead_time_days: 7,
      unit_cost: 4.25,
      selling_price: 6.50
    )
  end
  let(:user) do
    User.create!(
      first_name: "Inventory",
      last_name: "Lead",
      email: "inventory.lead@example.com",
      role: "department_manager",
      location: location,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  describe Product do
    it "belongs to catalog and supplier records and calculates stock totals" do
      StockLevel.find_or_create_by!(product: product, location: location).update!(
        current_quantity: 15,
        reserved_quantity: 4
      )

      expect(product.category).to eq(category)
      expect(product.supplier).to eq(supplier)
      expect(product.total_stock).to eq(15)
      expect(product.available_stock).to eq(11)
    end

    it "requires unique SKUs and non-negative prices" do
      Product.create!(name: "Original", sku: "SKU-001", category: category)
      duplicate = Product.new(name: "Duplicate", sku: "SKU-001", category: category, unit_cost: -1)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sku]).to be_present
      expect(duplicate.errors[:unit_cost]).to be_present
    end
  end

  describe Location do
    it "initializes stock levels for existing products when a location is created" do
      product

      new_location = Location.create!(name: "Overflow Warehouse")

      stock_level = new_location.stock_levels.find_by(product: product)
      expect(stock_level).to be_present
      expect(stock_level.current_quantity).to eq(0)
      expect(stock_level.reserved_quantity).to eq(0)
    end

    it "only allows inventory manager roles as location managers" do
      customer = User.create!(
        first_name: "Customer",
        last_name: "User",
        email: "customer.manager@example.com",
        role: "customer",
        password: "password123",
        password_confirmation: "password123"
      )

      invalid_location = Location.new(name: "Customer Managed", manager: customer)

      expect(invalid_location).not_to be_valid
      expect(invalid_location.errors[:manager]).to be_present
    end
  end

  describe Supplier do
    it "keeps products but clears supplier ownership when deleted" do
      product

      supplier.destroy!

      expect(product.reload.supplier).to be_nil
    end

    it "requires a positive default lead time" do
      invalid_supplier = Supplier.new(name: "Invalid Supply", default_lead_time_days: 0)

      expect(invalid_supplier).not_to be_valid
      expect(invalid_supplier.errors[:default_lead_time_days]).to be_present
    end
  end

  describe StockLevel do
    it "tracks available quantity and prevents duplicate product-location rows" do
      StockLevel.find_or_create_by!(product: product, location: location).update!(
        current_quantity: 20,
        reserved_quantity: 6
      )

      duplicate = StockLevel.new(product: product, location: location)

      expect(product.stock_levels.first.available_quantity).to eq(14)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to be_present
    end

    it "rejects negative stock values" do
      stock_level = StockLevel.new(product: product, location: location, current_quantity: -1, reserved_quantity: -1)

      expect(stock_level).not_to be_valid
      expect(stock_level.errors[:current_quantity]).to be_present
      expect(stock_level.errors[:reserved_quantity]).to be_present
    end
  end

  describe StockMovement do
    it "records inventory movement references across products, locations, and users" do
      movement = StockMovement.create!(
        product: product,
        destination_location: location,
        user: user,
        movement_type: "adjustment",
        quantity: 5,
        movement_date: Time.current
      )

      expect(product.stock_movements).to include(movement)
      expect(location.destination_movements).to include(movement)
      expect(user.stock_movements).to include(movement)
    end

    it "requires a valid movement type and positive quantity" do
      movement = StockMovement.new(
        product: product,
        destination_location: location,
        user: user,
        movement_type: "adjustment",
        quantity: 0,
        movement_date: Time.current
      )

      expect(movement).not_to be_valid
      expect(movement.errors[:quantity]).to be_present
      expect { movement.movement_type = "invalid" }.to raise_error(ArgumentError)
    end
  end
end

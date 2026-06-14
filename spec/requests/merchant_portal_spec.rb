require "rails_helper"

RSpec.describe "Merchant portal", type: :request do
  let!(:category) { Category.create!(name: "Industrial") }
  let!(:merchant_supplier) { Supplier.create!(name: "Merchant Alpha", default_lead_time_days: 7) }
  let!(:other_supplier) { Supplier.create!(name: "Merchant Beta", default_lead_time_days: 7) }
  let!(:merchant_user) { create_authenticated_user(role: "supplier", email: "merchant.portal@example.com") }
  let!(:merchant_link) { SupplierUser.create!(supplier: merchant_supplier, user: merchant_user) }
  let!(:merchant_product) do
    Product.create!(
      name: "Alpha Pump",
      sku: "ALPHA-PUMP",
      category: category,
      supplier: merchant_supplier,
      marketplace_status: "public",
      reorder_point: 10,
      lead_time_days: 7
    )
  end
  let!(:other_product) do
    Product.create!(
      name: "Beta Pump",
      sku: "BETA-PUMP",
      category: category,
      supplier: other_supplier,
      marketplace_status: "public",
      reorder_point: 10,
      lead_time_days: 7
    )
  end

  describe "GET /merchant" do
    it "allows linked supplier users to access the merchant dashboard" do
      login_as(merchant_user)

      get merchant_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Merchant Dashboard")
      expect(response.body).to include(merchant_supplier.name)
    end

    it "blocks unlinked supplier users" do
      unlinked_user = create_authenticated_user(role: "supplier", email: "unlinked.merchant@example.com")
      login_as(unlinked_user)

      get merchant_root_path

      expect(response).to have_http_status(:forbidden)
    end

    it "blocks customers and guests" do
      %w[customer guest].each do |role|
        user = create_authenticated_user(role: role, email: "#{role}.merchant@example.com")
        login_as(user)

        get merchant_root_path

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /merchant/products" do
    it "shows only the merchant's products" do
      login_as(merchant_user)

      get merchant_products_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(merchant_product.name)
      expect(response.body).not_to include(other_product.name)
    end
  end

  describe "POST /merchant/products" do
    it "assigns merchant-created products to the selected linked supplier" do
      login_as(merchant_user)

      expect do
        post merchant_products_path, params: {
          product: {
            name: "Alpha Sensor",
            sku: "ALPHA-SENSOR",
            category_id: category.id,
            supplier_id: merchant_supplier.id,
            marketplace_status: "draft",
            reorder_point: 10,
            lead_time_days: 7
          }
        }
      end.to change(Product, :count).by(1)

      product = Product.find_by!(sku: "ALPHA-SENSOR")
      expect(product.supplier).to eq(merchant_supplier)
      expect(response).to redirect_to(merchant_products_path)
    end

    it "rejects products assigned to another supplier" do
      login_as(merchant_user)

      expect do
        post merchant_products_path, params: {
          product: {
            name: "Beta Sensor",
            sku: "BETA-SENSOR",
            category_id: category.id,
            supplier_id: other_supplier.id,
            marketplace_status: "draft",
            reorder_point: 10,
            lead_time_days: 7
          }
        }
      end.not_to change(Product, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /merchant/products/:id" do
    it "allows merchants to edit their own products" do
      login_as(merchant_user)

      patch merchant_product_path(merchant_product), params: {
        product: {
          name: "Alpha Pump Updated",
          sku: merchant_product.sku,
          category_id: category.id,
          supplier_id: merchant_supplier.id,
          marketplace_status: "private",
          reorder_point: 10,
          lead_time_days: 7
        }
      }

      expect(response).to redirect_to(merchant_products_path)
      expect(merchant_product.reload.name).to eq("Alpha Pump Updated")
      expect(merchant_product.marketplace_status).to eq("private")
    end

    it "does not allow merchants to edit another supplier's products" do
      login_as(merchant_user)

      patch merchant_product_path(other_product), params: {
        product: {
          name: "Hijacked",
          sku: other_product.sku,
          category_id: category.id,
          supplier_id: merchant_supplier.id,
          reorder_point: 10,
          lead_time_days: 7
        }
      }

      expect(response).to have_http_status(:not_found)
      expect(other_product.reload.name).to eq("Beta Pump")
    end
  end

  describe "GET /merchant/inventory" do
    it "shows stock only for the merchant's products" do
      location = Location.create!(name: "Warehouse")
      StockLevel.find_or_create_by!(product: merchant_product, location: location).update!(current_quantity: 5)
      StockLevel.find_or_create_by!(product: other_product, location: location).update!(current_quantity: 9)
      login_as(merchant_user)

      get merchant_inventory_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(merchant_product.name)
      expect(response.body).not_to include(other_product.name)
    end
  end

  describe "GET /merchant/orders" do
    it "shows only marketplace order items for the merchant's suppliers" do
      customer = create_authenticated_user(role: "customer", email: "merchant.orders.customer@example.com")
      merchant_order = Order.create!(user: customer, order_number: "MO-MERCHANT", status: "confirmed", total_amount: 1)
      other_order = Order.create!(user: customer, order_number: "MO-OTHER", status: "confirmed", total_amount: 1)
      merchant_order.order_items.create!(product: merchant_product, supplier: merchant_supplier, quantity: 1, unit_price: 1, total_amount: 1)
      other_order.order_items.create!(product: other_product, supplier: other_supplier, quantity: 1, unit_price: 1, total_amount: 1)
      login_as(merchant_user)

      get merchant_orders_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("MO-MERCHANT")
      expect(response.body).not_to include("MO-OTHER")
    end
  end

  it "preserves existing admin/internal product access" do
    admin = create_authenticated_user(role: "admin", email: "admin.phase3@example.com")
    login_as(admin)

    get products_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(merchant_product.name)
    expect(response.body).to include(other_product.name)
  end
end

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

    it "allows account-backed merchant members through the mapped merchant profile" do
      account_user = create_authenticated_user(role: "customer", email: "account.merchant@example.com")
      account = Account.create_with_owner!(
        creator: account_user,
        name: "Account Merchant",
        account_type: "enterprise_merchant"
      )
      MerchantProfile.create!(account: account, supplier: merchant_supplier, display_name: "Account Merchant")
      login_as(account_user)

      get merchant_root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Merchant Dashboard")
      expect(response.body).to include(merchant_supplier.name)
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

    it "shows mapped supplier products for account-backed merchant members" do
      account_user = create_authenticated_user(role: "customer", email: "account.products@example.com")
      account = Account.create_with_owner!(
        creator: account_user,
        name: "Account Product Merchant",
        account_type: "individual_merchant"
      )
      MerchantProfile.create!(account: account, supplier: merchant_supplier, display_name: "Account Product Merchant")
      login_as(account_user)

      get merchant_products_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(merchant_product.name)
      expect(response.body).not_to include(other_product.name)
    end
  end

  describe "GET /merchant/catalog" do
    it "previews only the merchant's marketplace listings with visibility labels" do
      merchant_product.marketplace_listing.update!(status: "hidden", visibility: "private")
      other_product.marketplace_listing.update!(status: "active", visibility: "public")
      login_as(merchant_user)

      get merchant_catalog_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Marketplace Preview")
      expect(response.body).to include(merchant_product.name)
      expect(response.body).to include("Listing Hidden")
      expect(response.body).to include("Private")
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
      expect(response.body).to include("Location breakdown")
      expect(response.body).to include("List on marketplace")
      expect(response.body).to include("Keep private/local")
      expect(response.body).not_to include(other_product.name)
    end
  end

  describe "PATCH /merchant/inventory/products/:product_id/marketplace" do
    it "uses existing listing fields to list or keep products private" do
      login_as(merchant_user)

      patch merchant_inventory_product_marketplace_path(merchant_product), params: { visibility_choice: "local" }

      expect(response).to redirect_to(merchant_inventory_path)
      expect(merchant_product.reload.listing_scope).to eq("local")
      expect(merchant_product.marketplace_status).to eq("private")

      patch merchant_inventory_product_marketplace_path(merchant_product), params: { visibility_choice: "marketplace" }

      expect(response).to redirect_to(merchant_inventory_path)
      expect(merchant_product.reload.listing_scope).to eq("both")
      expect(merchant_product.marketplace_status).to eq("public")
      expect(merchant_product.marketplace_listing).to be_present
    end
  end

  describe "GET /merchant/services" do
    it "previews only the merchant's services with status labels" do
      ServiceListing.create!(
        name: "Alpha Install",
        supplier: merchant_supplier,
        service_category: "Electrical",
        status: "draft",
        visibility: "private"
      )
      ServiceListing.create!(
        name: "Beta Install",
        supplier: other_supplier,
        service_category: "Electrical",
        status: "public",
        visibility: "public"
      )
      login_as(merchant_user)

      get merchant_services_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Services Marketplace Preview")
      expect(response.body).to include("Alpha Install")
      expect(response.body).to include("Draft")
      expect(response.body).to include("Private")
      expect(response.body).not_to include("Beta Install")
    end
  end

  describe "GET /merchant/profile" do
    it "shows company information and hides enterprise tools for individual merchants" do
      account_user = create_authenticated_user(role: "customer", email: "individual.profile@example.com")
      account = Account.create_with_owner!(
        creator: account_user,
        name: "Solo Merchant",
        account_type: "individual_merchant"
      )
      MerchantProfile.create!(
        account: account,
        supplier: merchant_supplier,
        display_name: "Solo Shop",
        location: "Brooklyn",
        company_size: "1",
        contact_information: "solo@example.com",
        business_category: "Food",
        permits_and_licenses: "Food handler",
        controlled_goods_notes: "food"
      )
      login_as(account_user)

      get merchant_profile_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("theme-individual-merchant")
      expect(response.body).to include("Company Information")
      expect(response.body).to include("Solo Shop")
      expect(response.body).to include("Controlled goods indicators")
      expect(response.body).not_to include("Team management")
      expect(response.body).not_to include("Multiple-user settings")
      expect(response.body).not_to include(">Locations<")
    end

    it "shows enterprise tools to enterprise admins with existing permissions" do
      account_user = create_authenticated_user(role: "customer", email: "enterprise.profile@example.com")
      account = Account.create_with_owner!(
        creator: account_user,
        name: "Enterprise Merchant",
        account_type: "enterprise_merchant"
      )
      MerchantProfile.create!(
        account: account,
        supplier: merchant_supplier,
        display_name: "Enterprise Shop",
        business_category: "Regulated supplies"
      )
      login_as(account_user)

      get merchant_profile_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("theme-enterprise-merchant")
      expect(response.body).to include("Team management")
      expect(response.body).to include("Multiple-user settings")
      expect(response.body).to include("Multiple-location settings")
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

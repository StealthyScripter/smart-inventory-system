require "rails_helper"

RSpec.describe "Catalog", type: :request do
  let!(:category) { Category.create!(name: "Hardware") }
  let!(:supplier) { Supplier.create!(name: "Public Merchant", default_lead_time_days: 7) }
  let!(:public_product) do
    Product.create!(
      name: "Public Bolt",
      sku: "PUB-BOLT",
      category: category,
      supplier: supplier,
      selling_price: 12.50,
      marketplace_status: "public"
    )
  end
  let!(:private_product) do
    Product.create!(
      name: "Private Bolt",
      sku: "PRIV-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "private"
    )
  end
  let!(:draft_product) do
    Product.create!(
      name: "Draft Bolt",
      sku: "DRAFT-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "draft"
    )
  end
  let!(:archived_product) do
    Product.create!(
      name: "Archived Bolt",
      sku: "ARCH-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "archived"
    )
  end

  describe "GET /catalog" do
    it "is publicly accessible and lists public products" do
      get catalog_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(public_product.name)
      expect(response.body).to include(supplier.name)
    end

    it "hides private and draft products from public discovery" do
      get catalog_path

      expect(response.body).not_to include(private_product.name)
      expect(response.body).not_to include(draft_product.name)
      expect(response.body).not_to include(archived_product.name)
    end

    it "allows customers to browse public products" do
      customer = create_authenticated_user(role: "customer", email: "catalog.customer@example.com")
      login_as(customer)

      get catalog_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include(public_product.name)
    end

    it "searches public products by name" do
      Product.create!(name: "Public Nut", sku: "PUB-NUT", category: category, supplier: supplier, marketplace_status: "public")

      get catalog_path, params: { q: "Bolt" }

      expect(response.body).to include(public_product.name)
      expect(response.body).not_to include("Public Nut")
    end

    it "filters public products by category and merchant" do
      other_category = Category.create!(name: "Electrical")
      other_supplier = Supplier.create!(name: "Other Merchant", default_lead_time_days: 7)
      other_product = Product.create!(
        name: "Public Wire",
        sku: "PUB-WIRE",
        category: other_category,
        supplier: other_supplier,
        marketplace_status: "public"
      )

      get catalog_path, params: { category_id: other_category.id, supplier_id: other_supplier.id }

      expect(response.body).to include(other_product.name)
      expect(response.body).not_to include(public_product.name)
    end

    it "sorts public products by price" do
      cheaper = Product.create!(
        name: "Public Washer",
        sku: "PUB-WASHER",
        category: category,
        supplier: supplier,
        selling_price: 1.25,
        marketplace_status: "public"
      )

      get catalog_path, params: { sort: "price_asc" }

      expect(response.body.index(cheaper.name)).to be < response.body.index(public_product.name)
    end
  end

  describe "GET /catalog/:id" do
    it "shows public product details" do
      get catalog_product_path(public_product)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(public_product.name)
      expect(response.body).to include(public_product.sku)
    end

    it "does not expose private product details" do
      get catalog_product_path(private_product)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /merchants/:id" do
    it "shows only public products for a merchant storefront" do
      get merchant_storefront_path(supplier)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(supplier.name)
      expect(response.body).to include(public_product.name)
      expect(response.body).not_to include(private_product.name)
      expect(response.body).not_to include(draft_product.name)
    end
  end
end

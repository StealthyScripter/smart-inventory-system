# spec/requests/products_crud_spec.rb
require 'rails_helper'

RSpec.describe "Products CRUD", type: :request do
  let(:category) { Category.create!(name: "Electronics") }
  let(:supplier) { Supplier.create!(name: "Apple Inc.", default_lead_time_days: 7) }
  let(:location) { Location.create!(name: "Main Store") }

  let(:valid_attributes) {
    {
      name: "iPhone 15",
      sku: "IP15-001",
      description: "Latest iPhone model",
      unit_cost: 800.00,
      selling_price: 999.99,
      reorder_point: 10,
      lead_time_days: 7,
      category_id: category.id,
      supplier_id: supplier.id
    }
  }

  let(:invalid_attributes) {
    {
      name: "",
      sku: "",
      reorder_point: -1,
      lead_time_days: 0,
      category_id: nil
    }
  }

  describe "GET /products/new" do
    it "returns http success" do
      get new_product_path
      expect(response).to have_http_status(:success)
    end

    it "assigns a new product" do
      get new_product_path
      expect(assigns(:product)).to be_a_new(Product)
    end

    it "assigns categories and suppliers" do
      get new_product_path
      expect(assigns(:categories)).to include(category)
      expect(assigns(:suppliers)).to include(supplier)
    end
  end

  describe "POST /products" do
    context "with valid parameters" do
      it "creates a new Product" do
        expect {
          post products_path, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it "creates stock levels for all locations" do
        expect {
          post products_path, params: { product: valid_attributes }
        }.to change(StockLevel, :count).by(Location.count)
      end

      it "redirects to the created product" do
        post products_path, params: { product: valid_attributes }
        expect(response).to redirect_to(Product.last)
      end

      it "sets a success notice" do
        post products_path, params: { product: valid_attributes }
        follow_redirect!
        expect(response.body).to include('Product was successfully created')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Product" do
        expect {
          post products_path, params: { product: invalid_attributes }
        }.not_to change(Product, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post products_path, params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Add New Product')
      end
    end
  end

  describe "GET /products/:id/edit" do
    let!(:product) { Product.create!(valid_attributes) }

    it "returns http success" do
      get edit_product_path(product)
      expect(response).to have_http_status(:success)
    end

    it "assigns the requested product" do
      get edit_product_path(product)
      expect(assigns(:product)).to eq(product)
    end
  end

  describe "PATCH/PUT /products/:id" do
    let!(:product) { Product.create!(valid_attributes) }

    context "with valid parameters" do
      let(:new_attributes) {
        { name: "iPhone 15 Pro", selling_price: 1199.99 }
      }

      it "updates the requested product" do
        patch product_path(product), params: { product: new_attributes }
        product.reload
        expect(product.name).to eq("iPhone 15 Pro")
        expect(product.selling_price).to eq(1199.99)
      end

      it "redirects to the product" do
        patch product_path(product), params: { product: new_attributes }
        expect(response).to redirect_to(product)
      end
    end

    context "with invalid parameters" do
      it "renders the edit template with unprocessable_entity status" do
        patch product_path(product), params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Edit Product')
      end
    end
  end

  describe "DELETE /products/:id" do
    let!(:product) { Product.create!(valid_attributes) }

    it "destroys the requested product" do
      expect {
        delete product_path(product)
      }.to change(Product, :count).by(-1)
    end

    it "redirects to the products list" do
      delete product_path(product)
      expect(response).to redirect_to(products_url)
    end
  end
end

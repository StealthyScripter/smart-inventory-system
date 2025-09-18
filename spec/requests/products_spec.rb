require 'rails_helper'

RSpec.describe "Products", type: :request do
  let(:category) { Category.create!(name: "Electronics") }
  let!(:product) { Product.create!(name: "iPhone", sku: "IP001", category: category, reorder_point: 10, lead_time_days: 7) }

  describe "GET /products" do
    it "returns http success" do
      get products_path
      expect(response).to have_http_status(:success)
    end

    it "displays product list" do
      get products_path
      expect(response.body).to include("Product Catalog")
      expect(response.body).to include(product.name)
      expect(response.body).to include(product.sku)
    end

    it "includes product category" do
      get products_path
      expect(response.body).to include(category.name)
    end
  end

  describe "GET /products/:id" do
    it "returns http success" do
      get product_path(product)
      expect(response).to have_http_status(:success)
    end

    it "displays the specific product" do
      get product_path(product)
      expect(assigns(:product)).to eq(product)
    end
  end
end

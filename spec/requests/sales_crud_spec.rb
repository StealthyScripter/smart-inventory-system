require 'rails_helper'

RSpec.describe "Sales CRUD", type: :request do
  let(:category) { Category.create!(name: "Electronics") }
  let(:location) { Location.create!(name: "Main Store") }
  let(:user) { User.create!(first_name: "Jane", last_name: "Doe", email: "jane@example.com", role: "staff") }
  let(:product) { Product.create!(name: "iPhone", sku: "IP001", category: category, reorder_point: 10, lead_time_days: 7) }
  let!(:stock_level) { StockLevel.create!(product: product, location: location, current_quantity: 50) }

  let(:valid_attributes) {
    {
      product_id: product.id,
      location_id: location.id,
      user_id: user.id,
      customer_name: "John Customer",
      quantity: 2,
      unit_price: 999.99,
      total_amount: 1999.98
    }
  }

  let(:invalid_attributes) {
    {
      product_id: nil,
      location_id: nil,
      quantity: 0,
      unit_price: -100
    }
  }

  describe "GET /sales" do
    let!(:sales_transaction) {
      SalesTransaction.create!(
        product: product,
        location: location,
        user: user,
        quantity: 1,
        unit_price: 999.99,
        total_amount: 999.99,
        transaction_date: Time.current
      )
    }

    it "returns http success" do
      get sales_path
      expect(response).to have_http_status(:success)
    end

    it "assigns necessary data for the form and list" do
      get sales_path
      expect(assigns(:recent_transactions)).to include(sales_transaction)
      expect(assigns(:products)).to include(product)
      expect(assigns(:locations)).to include(location)
      expect(assigns(:sale)).to be_a_new(SalesTransaction)
    end
  end

  describe "GET /sales/new" do
    it "returns http success" do
      get new_sale_path
      expect(response).to have_http_status(:success)
    end

    it "assigns a new sale" do
      get new_sale_path
      expect(assigns(:sale)).to be_a_new(SalesTransaction)
    end
  end

  describe "POST /sales" do
    context "with valid parameters and sufficient stock" do
      it "creates a new SalesTransaction" do
        expect {
          post sales_path, params: { sales_transaction: valid_attributes }
        }.to change(SalesTransaction, :count).by(1)
      end

      it "updates stock levels" do
        original_quantity = stock_level.current_quantity
        post sales_path, params: { sales_transaction: valid_attributes }
        stock_level.reload
        expect(stock_level.current_quantity).to eq(original_quantity - valid_attributes[:quantity])
      end

      it "creates a stock movement record" do
        expect {
          post sales_path, params: { sales_transaction: valid_attributes }
        }.to change(StockMovement, :count).by(1)

        movement = StockMovement.last
        expect(movement.movement_type).to eq('sale')
        expect(movement.quantity).to eq(valid_attributes[:quantity])
      end

      it "redirects to sales index with success notice" do
        post sales_path, params: { sales_transaction: valid_attributes }
        expect(response).to redirect_to(sales_path)
        follow_redirect!
        expect(response.body).to include('Sale processed successfully')
      end
    end

    context "with insufficient stock" do
      let(:insufficient_stock_attributes) {
        valid_attributes.merge(quantity: 100) # More than available stock
      }

      it "does not create a new SalesTransaction" do
        expect {
          post sales_path, params: { sales_transaction: insufficient_stock_attributes }
        }.not_to change(SalesTransaction, :count)
      end

      it "does not update stock levels" do
        original_quantity = stock_level.current_quantity
        post sales_path, params: { sales_transaction: insufficient_stock_attributes }
        stock_level.reload
        expect(stock_level.current_quantity).to eq(original_quantity)
      end

      it "renders the new template with errors when coming from new form" do
        post sales_path, params: { sales_transaction: insufficient_stock_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Process New Sale')
        expect(response.body).to include('exceeds available stock')
      end

      it "renders the index template with errors when coming from quick sale form" do
        post sales_path, params: { sales_transaction: insufficient_stock_attributes },
             headers: { 'HTTP_REFERER' => sales_url }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Sales &amp; Transactions')
        expect(response.body).to include('exceeds available stock')
      end
    end

    context "with invalid parameters" do
      it "does not create a new SalesTransaction" do
        expect {
          post sales_path, params: { sales_transaction: invalid_attributes }
        }.not_to change(SalesTransaction, :count)
      end

      it "renders the new template with errors when coming from new form" do
        post sales_path, params: { sales_transaction: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Process New Sale')
      end

      it "renders the index template with errors when coming from quick sale form" do
        post sales_path, params: { sales_transaction: invalid_attributes },
             headers: { 'HTTP_REFERER' => sales_url }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('Sales &amp; Transactions')
      end
    end
  end

  describe "DELETE /sales/:id" do
    let!(:sales_transaction) {
      SalesTransaction.create!(
        product: product,
        location: location,
        user: user,
        quantity: 2,
        unit_price: 999.99,
        total_amount: 1999.98,
        transaction_date: Time.current
      )
    }

    before do
      # Simulate the stock reduction that would have happened during sale
      stock_level.update!(current_quantity: stock_level.current_quantity - sales_transaction.quantity)
    end

    it "destroys the requested sales transaction" do
      expect {
        delete sale_path(sales_transaction)
      }.to change(SalesTransaction, :count).by(-1)
    end

    it "restores the stock levels" do
      original_quantity = stock_level.current_quantity
      delete sale_path(sales_transaction)
      stock_level.reload
      expect(stock_level.current_quantity).to eq(original_quantity + sales_transaction.quantity)
    end

    it "redirects to sales index with notice" do
      delete sale_path(sales_transaction)
      expect(response).to redirect_to(sales_path)
      follow_redirect!
      expect(response.body).to include('Sale was successfully cancelled')
    end
  end
end

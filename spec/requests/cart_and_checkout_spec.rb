require "rails_helper"

RSpec.describe "Cart and checkout", type: :request do
  let!(:category) { Category.create!(name: "Cart Hardware") }
  let!(:supplier) { Supplier.create!(name: "Cart Merchant", default_lead_time_days: 7) }
  let!(:customer) { create_authenticated_user(role: "customer", email: "cart.customer@example.com") }
  let!(:public_product) do
    Product.create!(
      name: "Cart Bolt",
      sku: "CART-BOLT",
      category: category,
      supplier: supplier,
      selling_price: 5.25,
      marketplace_status: "public"
    )
  end
  let!(:private_product) do
    Product.create!(
      name: "Private Cart Bolt",
      sku: "PRIVATE-CART-BOLT",
      category: category,
      supplier: supplier,
      marketplace_status: "private"
    )
  end

  it "redirects guests to login when adding to cart" do
    post cart_path, params: { product_id: public_product.id, quantity: 1 }

    expect(response).to redirect_to(login_path)
  end

  it "allows customers to add public products to a persistent cart" do
    login_as(customer)

    expect do
      post cart_path, params: { product_id: public_product.id, quantity: 2 }
    end.to change(CartItem, :count).by(1)

    cart = customer.carts.find_by!(status: "active")
    expect(cart.cart_items.first.quantity).to eq(2)
    expect(response).to redirect_to(cart_path)
  end

  it "renders the cart page for an authenticated customer" do
    login_as(customer)

    get cart_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Your Cart")
    expect(response.body).to include("Your cart is empty.")
  end

  it "does not allow private products in the cart" do
    login_as(customer)

    expect do
      post cart_path, params: { product_id: private_product.id, quantity: 1 }
    end.not_to change(CartItem, :count)

    expect(response).to redirect_to(catalog_path)
  end

  it "updates and removes cart item quantities" do
    login_as(customer)
    post cart_path, params: { product_id: public_product.id, quantity: 1 }
    item = customer.carts.find_by!(status: "active").cart_items.first

    patch cart_path, params: { item_id: item.id, quantity: 3 }
    expect(item.reload.quantity).to eq(3)

    delete cart_path, params: { item_id: item.id }
    expect(CartItem.exists?(item.id)).to be(false)
  end

  it "displays checkout totals and creates a draft order" do
    login_as(customer)
    post cart_path, params: { product_id: public_product.id, quantity: 2 }

    get checkout_path
    expect(response).to have_http_status(:success)
    expect(response.body).to include("Cart Bolt")
    expect(response.body).to include("$10.50")

    expect do
      post checkout_path
    end.to change(Order, :count).by(1).and change(OrderItem, :count).by(1)

    order = customer.orders.last
    expect(order.status).to eq("pending")
    expect(order.total_amount).to eq(10.50)
  end
end

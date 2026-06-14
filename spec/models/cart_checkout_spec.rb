require "rails_helper"

RSpec.describe "Cart checkout models", type: :model do
  let(:category) { Category.create!(name: "Cart Models") }
  let(:supplier) { Supplier.create!(name: "Cart Supplier", default_lead_time_days: 7) }
  let(:user) do
    User.create!(
      first_name: "Cart",
      last_name: "Customer",
      email: "cart.model@example.com",
      role: "customer",
      password: "password123",
      password_confirmation: "password123"
    )
  end
  let(:product) do
    Product.create!(
      name: "Model Bolt",
      sku: "MODEL-BOLT",
      category: category,
      supplier: supplier,
      selling_price: 3.25,
      marketplace_status: "public"
    )
  end

  it "calculates cart item and cart totals" do
    cart = Cart.create!(user: user)
    CartItem.create!(cart: cart, product: product, quantity: 4)

    expect(cart.total_amount).to eq(13.0)
  end

  it "rejects non-public products" do
    private_product = Product.create!(name: "Private", sku: "PRIVATE-MODEL", category: category, marketplace_status: "private")
    cart = Cart.create!(user: user)
    item = CartItem.new(cart: cart, product: private_product, quantity: 1)

    expect(item).not_to be_valid
    expect(item.errors[:product]).to be_present
  end
end

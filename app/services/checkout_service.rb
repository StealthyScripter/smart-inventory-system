class CheckoutService
  def initialize(cart)
    @cart = cart
  end

  def create_order!
    raise ActiveRecord::RecordInvalid, cart if cart.cart_items.empty?

    Order.transaction do
      order = Order.create!(
        user: cart.user,
        status: "pending",
        total_amount: cart.total_amount,
        submitted_at: Time.current
      )

      cart.cart_items.includes(product: :supplier).find_each do |item|
        order.order_items.create!(
          product: item.product,
          supplier: item.product.supplier,
          quantity: item.quantity,
          unit_price: item.product.selling_price.to_d,
          total_amount: item.total_amount
        )
      end

      cart.update!(status: "checked_out")
      order
    end
  end

  private

  attr_reader :cart
end

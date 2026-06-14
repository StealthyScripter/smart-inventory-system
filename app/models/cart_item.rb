class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
  validate :product_must_be_public

  def total_amount
    quantity * product.selling_price.to_d
  end

  private

  def product_must_be_public
    return if product&.publicly_listed?

    errors.add(:product, "must be publicly available")
  end
end

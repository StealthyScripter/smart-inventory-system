class Cart < ApplicationRecord
  STATUSES = %w[active checked_out].freeze

  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :status, inclusion: { in: STATUSES }

  def total_amount
    cart_items.includes(:product).sum(&:total_amount)
  end
end

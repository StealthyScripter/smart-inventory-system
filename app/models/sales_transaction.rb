class SalesTransaction < ApplicationRecord
  belongs_to :product
  belongs_to :location
  belongs_to :user

  validates :quantity, :transaction_date, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end

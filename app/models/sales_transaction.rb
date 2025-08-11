class SalesTransaction < ApplicationRecord
  belongs_to :product
  belongs_to :location
  belongs_to :user
  has_many :stock_movements, as: :reference

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :transaction_date, presence: true

  before_save :calculate_total_amount

  private

  def calculate_total_amount
    self.total_amount = quantity * unit_price if quantity && unit_price
  end
end

class StockLevel < ApplicationRecord
  belongs_to :product
  belongs_to :location
  has_many :stock_movements
  
  validates :current_quantity, :reserved_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :location_id }
  
  def available_quantity
    current_quantity - reserved_quantity
  end
end
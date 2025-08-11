class PurchaseOrderItem < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_cost, :total_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_save :calculate_total_cost

  private

  def calculate_total_cost
    self.total_cost = quantity * unit_cost if quantity && unit_cost
  end
end

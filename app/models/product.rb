class Product < ApplicationRecord
  belongs_to :category
  belongs_to :supplier, optional: true
  has_many :stock_levels, dependent: :destroy
  has_many :sales_transactions, dependent: :destroy
  has_many :purchase_order_items, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :demand_forecasts, dependent: :destroy

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :unit_cost, :selling_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reorder_point, :lead_time_days, numericality: { greater_than: 0 }

  def total_stock
    stock_levels.sum(:current_quantity)
  end

  def available_stock
    stock_levels.sum("current_quantity - reserved_quantity")
  end
end

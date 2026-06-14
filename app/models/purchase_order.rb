class PurchaseOrder < ApplicationRecord
  STATUSES = %w[pending ordered received cancelled].freeze

  belongs_to :supplier
  belongs_to :user
  has_many :purchase_order_items, dependent: :destroy
  has_many :stock_movements, as: :reference, dependent: :nullify

  validates :order_number, :order_date, presence: true
  validates :order_number, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
end

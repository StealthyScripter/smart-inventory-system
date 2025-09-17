class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  has_many :purchase_order_items, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, :order_date, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  enum :status, { pending: "pending", ordered: "ordered", received: "received", cancelled: "cancelled" }
end

class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  has_many :purchase_order_items, dependent: :destroy
  has_many :products, through: :purchase_order_items
  has_many :stock_movements, as: :reference

  accepts_nested_attributes_for :purchase_order_items,
                                allow_destroy: true,
                                reject_if: :all_blank

  validates :order_number, presence: true, uniqueness: true
  validates :status, :order_date, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  enum :status, { pending: "pending", ordered: "ordered", received: "received", cancelled: "cancelled" }

  before_save :calculate_total

  private

  def calculate_total
    self.total_amount = purchase_order_items.sum(&:total_cost)
  end
end

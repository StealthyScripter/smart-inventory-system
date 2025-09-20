class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :source_location, class_name: "Location", optional: true
  belongs_to :destination_location, class_name: "Location", optional: true
  belongs_to :reference, polymorphic: true, optional: true
  belongs_to :user

  validates :movement_type, :quantity, :movement_date, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  enum :movement_type, {
    sale: "sale",
    purchase: "purchase",
    transfer: "transfer",
    adjustment: "adjustment",
    return: "return"
  }
end

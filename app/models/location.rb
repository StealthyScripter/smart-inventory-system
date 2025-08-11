class Location < ApplicationRecord
  belongs_to :manager, class_name: "User", optional: true
  has_many :users, dependent: :nullify
  has_many :stock_levels, dependent: :destroy
  has_many :sales_transactions, dependent: :destroy
  has_many :source_movements, class_name: "StockMovement", foreign_key: "source_location_id"
  has_many :destination_movements, class_name: "StockMovement", foreign_key: "destination_location_id"
  has_many :demand_forecasts, dependent: :destroy

  validates :name, presence: true
end

class Location < ApplicationRecord
  belongs_to :manager, class_name: "User", optional: true
  has_many :users, dependent: :nullify
  has_many :stock_levels, dependent: :destroy
  has_many :source_movements, class_name: "StockMovement", foreign_key: "source_location_id"
  has_many :destination_movements, class_name: "StockMovement", foreign_key: "destination_location_id"

  validates :name, presence: true
  validate :manager_must_be_inventory_manager

  after_create :initialize_stock_levels

  private

  def manager_must_be_inventory_manager
    return if manager.blank?
    return if manager.admin? || manager.regional_manager? || manager.location_manager?

    errors.add(:manager, "must be an admin, regional manager, or location manager")
  end

  def initialize_stock_levels
    Product.find_each do |product|
      stock_levels.find_or_create_by!(product: product) do |stock_level|
        stock_level.current_quantity = 0
        stock_level.reserved_quantity = 0
      end
    end
  end
end

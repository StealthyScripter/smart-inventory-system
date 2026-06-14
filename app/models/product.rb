class Product < ApplicationRecord
  MARKETPLACE_STATUSES = %w[draft public private archived].freeze

  belongs_to :category
  belongs_to :supplier, optional: true
  has_many :stock_levels, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :purchase_order_items, dependent: :restrict_with_error
  has_many :sales_transactions, dependent: :restrict_with_error
  has_many :demand_forecasts, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :unit_cost, :selling_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reorder_point, :lead_time_days, numericality: { greater_than: 0 }
  validates :marketplace_status, inclusion: { in: MARKETPLACE_STATUSES }

  scope :publicly_listed, -> { where(marketplace_status: "public") }
  scope :active_marketplace, -> { where.not(marketplace_status: "archived") }
  scope :owned_by_suppliers, ->(supplier_ids) { where(supplier_id: supplier_ids) }
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    left_joins(:category, :supplier)
      .where(
        "products.name LIKE :pattern OR products.sku LIKE :pattern OR products.description LIKE :pattern OR " \
        "categories.name LIKE :pattern OR suppliers.name LIKE :pattern",
        pattern: pattern
      )
  }
  scope :for_category, ->(category_id) { category_id.present? ? where(category_id: category_id) : all }
  scope :for_supplier, ->(supplier_id) { supplier_id.present? ? where(supplier_id: supplier_id) : all }

  def self.catalog_sorted(sort)
    case sort
    when "price_asc"
      order(Arel.sql("COALESCE(products.selling_price, 0) ASC"), :name)
    when "price_desc"
      order(Arel.sql("COALESCE(products.selling_price, 0) DESC"), :name)
    when "newest"
      order(created_at: :desc)
    else
      order(:name)
    end
  end

  def total_stock
    stock_levels.sum(:current_quantity)
  end

  def available_stock
    stock_levels.sum("current_quantity - reserved_quantity")
  end

  def publicly_listed?
    marketplace_status == "public"
  end

  def average_rating
    reviews.published.average(:rating).to_f
  end
end

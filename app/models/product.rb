class Product < ApplicationRecord
  include SoftDeletable
  include ImageAttachmentValidatable

  MARKETPLACE_STATUSES = %w[draft public private archived].freeze
  LISTING_SCOPES = %w[local marketplace both].freeze

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
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :moderation_actions, as: :moderatable, dependent: :destroy
  has_one_attached :featured_image
  has_many_attached :images

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :unit_cost, :selling_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reorder_point, :lead_time_days, numericality: { greater_than: 0 }
  validates :marketplace_status, inclusion: { in: MARKETPLACE_STATUSES }
  validates :listing_scope, inclusion: { in: LISTING_SCOPES }
  validates :barcode_value, uniqueness: true, allow_blank: true
  validates_image_attachments :featured_image, :images

  before_validation :assign_generated_sku, on: :create
  before_validation :assign_barcode_value

  scope :marketplace_available, -> { where(listing_scope: ["marketplace", "both"]) }
  scope :local_only, -> { where(listing_scope: "local") }
  scope :publicly_listed, -> { where(marketplace_status: "public").marketplace_available }
  scope :active_marketplace, -> { where.not(marketplace_status: "archived") }
  scope :owned_by_suppliers, ->(supplier_ids) { where(supplier_id: supplier_ids) }
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    left_joins(:category, :supplier)
      .where(
        "products.name LIKE :pattern OR products.sku LIKE :pattern OR products.description LIKE :pattern OR " \
        "products.search_tags LIKE :pattern OR categories.name LIKE :pattern OR suppliers.name LIKE :pattern",
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
    when "rating"
      left_joins(:reviews)
        .group("products.id")
        .order(Arel.sql("AVG(reviews.rating) DESC"), :name)
    else
      order(:name)
    end
  end

  def total_stock
    return stock_levels.sum(&:current_quantity) if stock_levels.loaded?

    stock_levels.sum(:current_quantity)
  end

  def available_stock
    return stock_levels.sum { |stock_level| stock_level.current_quantity - stock_level.reserved_quantity } if stock_levels.loaded?

    stock_levels.sum("current_quantity - reserved_quantity")
  end

  def publicly_listed?
    marketplace_status == "public"
  end

  def average_rating
    reviews.published.average(:rating).to_f
  end

  def soft_delete!
    update!(discarded_at: Time.current, marketplace_status: "archived")
  end

  def restore!
    update!(discarded_at: nil, marketplace_status: "public")
  end

  private

  def assign_generated_sku
    self.sku = SkuGenerator.call(self) if sku.blank?
  end

  def assign_barcode_value
    self.barcode_value = sku if barcode_value.blank? && sku.present?
  end
end

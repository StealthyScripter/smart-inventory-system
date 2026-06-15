class ServiceListing < ApplicationRecord
  include SoftDeletable
  include ImageAttachmentValidatable

  CATEGORIES = [
    "Interior design",
    "Plumbing",
    "Electrical",
    "AC services",
    "Painting",
    "Roofing",
    "Carpentry",
    "Cleaning",
    "Equipment rental"
  ].freeze
  STATUSES = %w[draft public paused archived].freeze
  VISIBILITIES = %w[public private].freeze

  belongs_to :supplier
  belongs_to :account, optional: true
  has_many :reviews, dependent: :destroy
  has_many :service_booking_items, dependent: :destroy
  has_many :service_bookings, through: :service_booking_items
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :moderation_actions, as: :moderatable, dependent: :destroy
  has_one :marketplace_listing, dependent: :destroy
  has_many_attached :gallery_images
  has_many_attached :before_images
  has_many_attached :after_images

  validates :name, :service_category, presence: true
  validates :service_category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :starting_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates_image_attachments :gallery_images, :before_images, :after_images

  scope :publicly_listed, -> { where(status: "public", visibility: "public") }
  scope :for_supplier, ->(supplier_ids) { where(supplier_id: supplier_ids) }
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    where(
      "service_listings.name LIKE :pattern OR service_listings.description LIKE :pattern OR " \
      "service_listings.service_category LIKE :pattern OR service_listings.search_tags LIKE :pattern",
      pattern: pattern
    )
  }

  scope :for_category, ->(category) { category.present? ? where(service_category: category) : all }
  scope :for_supplier, ->(supplier_id) { supplier_id.present? ? where(supplier_id: supplier_id) : all }

  def self.catalog_sorted(sort)
    case sort
    when "price_asc"
      order(Arel.sql("COALESCE(service_listings.starting_price, 0) ASC"), :name)
    when "price_desc"
      order(Arel.sql("COALESCE(service_listings.starting_price, 0) DESC"), :name)
    when "newest"
      order(created_at: :desc)
    when "rating"
      left_joins(:reviews)
        .group("service_listings.id")
        .order(Arel.sql("AVG(reviews.rating) DESC"), :name)
    else
      order(:service_category, :name)
    end
  end

  def average_rating
    reviews.published.average(:rating).to_f
  end

  def merchant_account
    account || supplier&.merchant_account
  end

  def soft_delete!
    update!(discarded_at: Time.current, status: "archived")
  end

  def restore!
    update!(discarded_at: nil, status: "public")
  end
end

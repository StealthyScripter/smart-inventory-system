class Supplier < ApplicationRecord
  include SoftDeletable
  include ImageAttachmentValidatable
  include MarketplaceTaggable

  SHOP_STATUSES = %w[draft public paused].freeze

  has_many :products, dependent: :nullify
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :supplier_users, dependent: :destroy
  has_many :users, through: :supplier_users
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :service_listings, dependent: :destroy
  has_many :service_bookings, dependent: :restrict_with_error
  has_many :availability_slots, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :moderation_actions, as: :moderatable, dependent: :destroy
  has_one :merchant_profile, dependent: :nullify
  has_one :merchant_account, through: :merchant_profile, source: :account
  has_one_attached :logo
  has_one_attached :banner

  validates :name, presence: true
  validates :default_lead_time_days, presence: true, numericality: { greater_than: 0 }
  validates :shop_status, inclusion: { in: SHOP_STATUSES }
  validates :shop_slug, uniqueness: true, allow_blank: true
  validates :shop_slug, format: { with: /\A[a-z0-9-]+\z/ }, allow_blank: true
  validates_image_attachments :logo, :banner

  before_validation :normalize_shop_slug

  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    where(
      "name LIKE :pattern OR shop_description LIKE :pattern OR address LIKE :pattern OR search_tags LIKE :pattern",
      pattern: pattern
    )
  }

  def average_rating
    reviews.published.average(:rating).to_f
  end

  def public_shop?
    shop_status == "public"
  end

  def soft_delete!
    update!(discarded_at: Time.current, shop_status: "paused")
  end

  def restore!
    update!(discarded_at: nil, shop_status: "public")
  end

  private

  def normalize_shop_slug
    self.shop_slug = shop_slug.to_s.parameterize if shop_slug.present?
  end
end

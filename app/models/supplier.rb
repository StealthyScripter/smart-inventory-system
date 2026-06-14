class Supplier < ApplicationRecord
  SHOP_STATUSES = %w[draft public paused].freeze

  has_many :products, dependent: :nullify
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :supplier_users, dependent: :destroy
  has_many :users, through: :supplier_users
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :service_listings, dependent: :destroy

  validates :name, presence: true
  validates :default_lead_time_days, presence: true, numericality: { greater_than: 0 }
  validates :shop_status, inclusion: { in: SHOP_STATUSES }
  validates :shop_slug, uniqueness: true, allow_blank: true
  validates :shop_slug, format: { with: /\A[a-z0-9-]+\z/ }, allow_blank: true

  before_validation :normalize_shop_slug

  def average_rating
    reviews.published.average(:rating).to_f
  end

  def public_shop?
    shop_status == "public"
  end

  private

  def normalize_shop_slug
    self.shop_slug = shop_slug.to_s.parameterize if shop_slug.present?
  end
end

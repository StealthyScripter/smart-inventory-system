class MarketplaceListing < ApplicationRecord
  STATUSES = %w[draft active hidden archived].freeze
  VISIBILITIES = %w[public private].freeze
  LISTING_TYPES = %w[product service].freeze

  belongs_to :account, optional: true
  belongs_to :product, optional: true
  belongs_to :service_listing, optional: true

  validates :title, :status, :visibility, :listing_type, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :listing_type, inclusion: { in: LISTING_TYPES }
  validates :public_price, :sale_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :listed_record_present

  scope :visible, -> { where(status: "active", visibility: "public") }
  scope :products, -> { where(listing_type: "product") }
  scope :services, -> { where(listing_type: "service") }

  def visible?
    status == "active" && visibility == "public"
  end

  private

  def listed_record_present
    return if product.present? || service_listing.present?

    errors.add(:base, "must reference a product or service")
  end
end

class MerchantProfile < ApplicationRecord
  STATUSES = %w[draft public paused].freeze

  belongs_to :account
  belongs_to :supplier, optional: true

  validates :display_name, :status, presence: true
  validates :default_listing_status, :default_inventory_policy, presence: true
  validates :default_fulfillment_days, numericality: { greater_than: 0 }
  validates :account_id, uniqueness: true
  validates :supplier_id, uniqueness: true, allow_nil: true
  validates :status, inclusion: { in: STATUSES }
  validates :slug, uniqueness: true, allow_blank: true
  validates :slug, format: { with: /\A[a-z0-9-]+\z/ }, allow_blank: true
  validate :account_must_be_merchant

  before_validation :normalize_slug

  private

  def account_must_be_merchant
    return if account&.merchant?

    errors.add(:account, "must be a merchant account")
  end

  def normalize_slug
    self.slug = slug.to_s.parameterize if slug.present?
  end
end

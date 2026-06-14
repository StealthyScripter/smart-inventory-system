class Review < ApplicationRecord
  include SoftDeletable
  include ImageAttachmentValidatable

  STATUSES = %w[published hidden].freeze

  belongs_to :user
  belongs_to :product, optional: true
  belongs_to :supplier
  belongs_to :order_item, optional: true
  belongs_to :service_listing, optional: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :moderation_actions, as: :moderatable, dependent: :destroy
  has_many_attached :photos

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :status, inclusion: { in: STATUSES }
  validates :order_item_id, uniqueness: { scope: :user_id }
  validates_image_attachments :photos
  validate :must_be_for_completed_purchase
  validate :must_review_product_or_service

  scope :published, -> { where(status: "published") }

  def verified_purchase?
    order_item.present?
  end

  def soft_delete!
    update!(discarded_at: Time.current, status: "hidden")
  end

  def restore!
    update!(discarded_at: nil, status: "published")
  end

  private

  def must_be_for_completed_purchase
    return if service_listing.present?
    return if order_item&.order&.user == user &&
      order_item.product == product &&
      order_item.supplier == supplier &&
      order_item.fulfillment_status == "delivered"

    errors.add(:order_item, "must be a delivered purchase by this customer")
  end

  def must_review_product_or_service
    return if product.present? || service_listing.present?

    errors.add(:base, "must review a product or service")
  end
end

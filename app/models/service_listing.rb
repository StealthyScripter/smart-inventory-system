class ServiceListing < ApplicationRecord
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

  belongs_to :supplier
  has_many :reviews, dependent: :destroy

  validates :name, :service_category, presence: true
  validates :service_category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :starting_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :publicly_listed, -> { where(status: "public") }
  scope :for_supplier, ->(supplier_ids) { where(supplier_id: supplier_ids) }
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    where("name LIKE :pattern OR description LIKE :pattern OR service_category LIKE :pattern", pattern: pattern)
  }

  def average_rating
    reviews.published.average(:rating).to_f
  end
end

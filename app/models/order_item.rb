class OrderItem < ApplicationRecord
  FULFILLMENT_STATUSES = %w[pending processing packed shipped delivered cancelled].freeze
  TRANSITIONS = {
    "pending" => %w[processing cancelled],
    "processing" => %w[packed cancelled],
    "packed" => %w[shipped],
    "shipped" => %w[delivered],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  belongs_to :order
  belongs_to :product
  belongs_to :supplier
  has_many :reviews, dependent: :restrict_with_error

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :fulfillment_status, inclusion: { in: FULFILLMENT_STATUSES }

  def transition_to!(new_status)
    new_status = new_status.to_s
    raise ArgumentError, "invalid fulfillment transition" unless TRANSITIONS.fetch(fulfillment_status).include?(new_status)

    update!(fulfillment_status: new_status)
  end
end

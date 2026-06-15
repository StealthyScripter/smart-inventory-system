class Order < ApplicationRecord
  STATUSES = %w[pending confirmed processing packed shipped delivered cancelled returned].freeze
  TRANSITIONS = {
    "pending" => %w[confirmed cancelled],
    "confirmed" => %w[processing cancelled],
    "processing" => %w[packed cancelled],
    "packed" => %w[shipped],
    "shipped" => %w[delivered],
    "delivered" => %w[returned],
    "cancelled" => [],
    "returned" => []
  }.freeze

  belongs_to :user
  belongs_to :customer_account, class_name: "Account", optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_order_number, on: :create

  def transition_to!(new_status)
    new_status = new_status.to_s
    raise ArgumentError, "invalid status transition" unless TRANSITIONS.fetch(status).include?(new_status)

    update!(status: new_status)
  end

  private

  def assign_order_number
    self.order_number ||= "MO-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end

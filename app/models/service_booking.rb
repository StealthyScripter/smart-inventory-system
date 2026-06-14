class ServiceBooking < ApplicationRecord
  STATUSES = %w[requested accepted scheduled in_progress completed cancelled].freeze
  TRANSITIONS = {
    "requested" => %w[accepted scheduled cancelled],
    "accepted" => %w[scheduled cancelled],
    "scheduled" => %w[in_progress cancelled],
    "in_progress" => %w[completed cancelled],
    "completed" => [],
    "cancelled" => []
  }.freeze

  belongs_to :user
  belongs_to :supplier
  has_many :service_booking_items, dependent: :destroy
  has_many :service_listings, through: :service_booking_items

  validates :booking_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :assign_booking_number, on: :create

  def transition_to!(new_status)
    new_status = new_status.to_s
    raise ArgumentError, "invalid booking transition" unless TRANSITIONS.fetch(status).include?(new_status)

    update!(status: new_status)
  end

  private

  def assign_booking_number
    self.booking_number ||= "SB-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end

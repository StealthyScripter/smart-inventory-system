class AvailabilitySlot < ApplicationRecord
  belongs_to :supplier

  validates :available_date, :start_time, :end_time, presence: true
end

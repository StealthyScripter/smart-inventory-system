class ServiceBookingItem < ApplicationRecord
  belongs_to :service_booking
  belongs_to :service_listing

  validates :quoted_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end

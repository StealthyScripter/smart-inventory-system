class DemandForecast < ApplicationRecord
  PERIOD_TYPES = %w[daily weekly monthly quarterly yearly].freeze

  belongs_to :product
  belongs_to :location

  validates :forecast_date, :period_type, presence: true
  validates :period_type, inclusion: { in: PERIOD_TYPES }
  validates :predicted_demand, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :confidence_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
  validates :product_id, uniqueness: { scope: [:location_id, :forecast_date, :period_type] }
end

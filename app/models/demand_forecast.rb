class DemandForecast < ApplicationRecord
  belongs_to :product
  belongs_to :location
  
  validates :forecast_date, :period_type, :predicted_demand, presence: true
  validates :predicted_demand, numericality: { greater_than_or_equal_to: 0 }
  validates :confidence_score, numericality: { in: 0.0..1.0 }, allow_nil: true
  validates :product_id, uniqueness: { scope: [:location_id, :forecast_date, :period_type] }
  
  enum period_type: { daily: 'daily', weekly: 'weekly', monthly: 'monthly' }
end
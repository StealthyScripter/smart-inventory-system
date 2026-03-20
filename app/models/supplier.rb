class Supplier < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :default_lead_time_days, presence: true, numericality: { greater_than: 0 }
end

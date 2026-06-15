class Payment < ApplicationRecord
  STATUSES = %w[pending authorized paid failed refunded].freeze
  PROVIDERS = %w[manual stripe].freeze

  belongs_to :order

  validates :provider, inclusion: { in: PROVIDERS }
  validates :status, inclusion: { in: STATUSES }
  validates :amount, numericality: { greater_than: 0 }
  validates :currency, presence: true

  def paid?
    status == "paid"
  end
end

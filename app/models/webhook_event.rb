class WebhookEvent < ApplicationRecord
  STATUSES = %w[received processed rejected].freeze

  validates :provider, :external_id, :event_type, :payload, presence: true
  validates :external_id, uniqueness: { scope: :provider }
  validates :status, inclusion: { in: STATUSES }

  def parsed_payload
    JSON.parse(payload)
  end
end

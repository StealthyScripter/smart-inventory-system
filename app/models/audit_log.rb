class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true

  def self.record!(actor:, auditable:, action:, details: {})
    create!(
      actor: actor,
      auditable: auditable,
      action: action,
      details: JSON.generate(details)
    )
  end

  def parsed_details
    JSON.parse(details.presence || "{}")
  end
end

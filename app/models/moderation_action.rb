class ModerationAction < ApplicationRecord
  ACTIONS = %w[hide approve suspend dismiss_report resolve_report].freeze

  belongs_to :actor, class_name: "User"
  belongs_to :moderatable, polymorphic: true

  validates :action_name, inclusion: { in: ACTIONS }
end

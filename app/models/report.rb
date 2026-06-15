class Report < ApplicationRecord
  STATUSES = %w[open reviewed resolved dismissed].freeze

  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true
  belongs_to :account, optional: true
  has_many :moderation_actions, as: :moderatable, dependent: :destroy

  validates :reason, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :open, -> { where(status: "open") }
end

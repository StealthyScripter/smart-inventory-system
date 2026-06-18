class Tagging < ApplicationRecord
  TAGGABLE_TYPES = %w[Product ServiceListing Supplier].freeze

  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  validates :tag_id, uniqueness: { scope: [:taggable_type, :taggable_id] }
  validates :taggable_type, inclusion: { in: TAGGABLE_TYPES }
end

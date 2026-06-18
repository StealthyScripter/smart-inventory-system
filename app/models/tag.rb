class Tag < ApplicationRecord
  CONTEXTS = %w[category supplier service action event condition audience season].freeze

  has_many :taggings, dependent: :destroy

  validates :name, :slug, :context, presence: true
  validates :slug, uniqueness: { scope: :context }
  validates :context, inclusion: { in: CONTEXTS }
  validates :position, numericality: { only_integer: true }

  before_validation :normalize_identity

  scope :for_marketplace_sections, -> { where(marketplace_section: true).order(:position, :name) }

  def label
    display_name.presence || name
  end

  def qualified_name
    "#{context}:#{name}"
  end

  private

  def normalize_identity
    self.name = name.to_s.strip
    self.context = context.to_s.strip.parameterize(separator: "_")
    self.slug = (slug.presence || name).to_s.parameterize
  end
end

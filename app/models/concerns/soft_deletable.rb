module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active_records, -> { where(discarded_at: nil) }
    scope :discarded, -> { where.not(discarded_at: nil) }
  end

  def soft_delete!
    update!(discarded_at: Time.current)
  end

  def restore!
    update!(discarded_at: nil)
  end

  def discarded?
    discarded_at.present?
  end
end

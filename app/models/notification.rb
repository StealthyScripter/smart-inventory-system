class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :account, optional: true

  validates :event_type, :title, presence: true

  scope :unread, -> { where(read_at: nil) }
end

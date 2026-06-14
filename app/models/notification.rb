class Notification < ApplicationRecord
  belongs_to :user

  validates :event_type, :title, presence: true

  scope :unread, -> { where(read_at: nil) }
end

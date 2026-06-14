class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true
  validate :sender_must_participate

  scope :unread, -> { where(read_at: nil) }

  private

  def sender_must_participate
    return if conversation&.participant?(sender)

    errors.add(:sender, "must be part of the conversation")
  end
end

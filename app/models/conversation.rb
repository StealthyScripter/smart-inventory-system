class Conversation < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :supplier
  belongs_to :account, optional: true
  belongs_to :order, optional: true
  belongs_to :service_booking, optional: true
  has_many :messages, dependent: :destroy

  validates :subject, presence: true

  def participant?(user)
    user == customer ||
      supplier.users.exists?(id: user.id) ||
      account&.account_memberships&.active&.exists?(user: user)
  end
end

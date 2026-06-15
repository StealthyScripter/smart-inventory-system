class CustomerProfile < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :account_id, uniqueness: true
  validate :account_must_be_customer

  private

  def account_must_be_customer
    return if account&.customer?

    errors.add(:account, "must be a customer account")
  end
end

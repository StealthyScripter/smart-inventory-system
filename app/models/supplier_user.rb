class SupplierUser < ApplicationRecord
  belongs_to :supplier
  belongs_to :user

  validates :supplier_id, uniqueness: { scope: :user_id }
  validate :user_must_have_supplier_role

  private

  def user_must_have_supplier_role
    return if user&.supplier_user?

    errors.add(:user, "must have the supplier role")
  end
end

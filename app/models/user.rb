class User < ApplicationRecord
  has_secure_password

  belongs_to :location, optional: true
  has_many :sales_transactions, dependent: :destroy
  has_many :purchase_orders, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :managed_locations, class_name: "Location", foreign_key: "manager_id"

  before_validation :set_default_role, on: :create
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, :role, presence: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  private

  def set_default_role
    self.role ||= "employee"
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

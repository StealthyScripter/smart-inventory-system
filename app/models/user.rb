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
  validates :role, inclusion: { in: %w[admin manager supervisor employee guest] }

  # Validate that supervisor and employee must have a location
  validate :location_required_for_scoped_roles

  def full_name
    "#{first_name} #{last_name}"
  end

  # Role check methods
  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def supervisor?
    role == "supervisor"
  end

  def employee?
    role == "employee"
  end

  def guest?
    role == "guest"
  end

  private

  def set_default_role
    self.role ||= "guest" # Changed from "employee" to "guest"
  end

  def location_required_for_scoped_roles
    if (supervisor? || employee?) && location_id.blank?
      errors.add(:location, "must be assigned for #{role} role")
    end
  end
end

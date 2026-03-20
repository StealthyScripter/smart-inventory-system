class User < ApplicationRecord
  ROLE_ALIASES = {
    "manager" => "regional_manager",
    "supervisor" => "location_manager",
    "staff" => "employee"
  }.freeze

  ROLE_HIERARCHY = %w[
    guest
    customer
    supplier
    client
    employee
    department_manager
    location_manager
    regional_manager
    admin
  ].freeze

  LOCATION_SCOPED_ROLES = %w[location_manager department_manager employee].freeze

  has_secure_password

  belongs_to :location, optional: true
  has_many :stock_movements, dependent: :destroy
  has_many :managed_locations, class_name: "Location", foreign_key: "manager_id"

  before_validation :normalize_role
  before_validation :set_default_role, on: :create
  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, :role, presence: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :role, inclusion: { in: ROLE_HIERARCHY }
  after_update :log_role_change, if: :saved_change_to_role

  validate :location_required_for_scoped_roles

  def self.normalize_role(value)
    normalized = value.to_s.strip
    ROLE_ALIASES.fetch(normalized, normalized)
  end

  def self.roles_for_query(roles)
    normalized_roles = Array(roles).flatten.compact.map { |role| normalize_role(role) }.uniq
    legacy_roles = ROLE_ALIASES.select { |_legacy, normalized| normalized_roles.include?(normalized) }.keys

    normalized_roles + legacy_roles
  end

  def self.with_roles(*roles)
    where(role: roles_for_query(roles.flatten))
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def normalized_role
    self.class.normalize_role(role)
  end

  def role_name
    normalized_role.tr("_", " ").titleize
  end

  def admin?
    normalized_role == "admin"
  end

  def regional_manager?
    normalized_role == "regional_manager"
  end

  def location_manager?
    normalized_role == "location_manager"
  end

  def department_manager?
    normalized_role == "department_manager"
  end

  def employee?
    normalized_role == "employee"
  end

  def client?
    normalized_role == "client"
  end

  def supplier_user?
    normalized_role == "supplier"
  end

  def customer?
    normalized_role == "customer"
  end

  def guest?
    normalized_role == "guest"
  end

  # Backward-compatible aliases while the rest of the app is cleaned up.
  def manager?
    regional_manager?
  end

  def supervisor?
    location_manager?
  end

  private

  def set_default_role
    self.role ||= "guest"
  end

  def normalize_role
    self.role = self.class.normalize_role(role) if role.present?
  end

  def location_required_for_scoped_roles
    if LOCATION_SCOPED_ROLES.include?(normalized_role) && location_id.blank?
      errors.add(:location, "must be assigned for #{role} role")
    end
  end

  def log_role_change
    Rails.logger.warn(
      "SECURITY: User role changed - " \
      "User ID: #{id}, " \
      "From: #{role_before_last_save}, " \
      "To: #{role}, " \
      "Changed at: #{updated_at}"
    )
  end
end

class AccountMembership < ApplicationRecord
  ROLES = %w[
    owner
    admin
    manager
    catalog_manager
    inventory_manager
    order_manager
    service_manager
    support_staff
    employee
    viewer
  ].freeze
  ALL_PERMISSIONS = %i[
    manage_catalog
    publish_listings
    archive_listings
    manage_inventory
    view_inventory
    adjust_stock
    manage_locations
    view_orders
    manage_orders
    fulfill_orders
    manage_services
    manage_bookings
    manage_account_settings
    manage_members
    manage_roles
  ].freeze
  PERMISSIONS_BY_ROLE = {
    "owner" => ALL_PERMISSIONS,
    "admin" => ALL_PERMISSIONS,
    "manager" => ALL_PERMISSIONS - %i[manage_members manage_roles],
    "catalog_manager" => %i[manage_catalog publish_listings archive_listings],
    "inventory_manager" => %i[manage_inventory view_inventory adjust_stock manage_locations],
    "order_manager" => %i[view_orders manage_orders fulfill_orders],
    "service_manager" => %i[manage_services manage_bookings],
    "support_staff" => %i[view_orders manage_bookings],
    "employee" => %i[view_inventory view_orders],
    "viewer" => %i[view_inventory view_orders]
  }.freeze

  belongs_to :account
  belongs_to :user

  before_validation :set_default_role, on: :create

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :account_id }
  validate :individual_merchant_has_one_active_membership

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :owners_or_admins, -> { where(role: %w[owner admin]) }

  def owner?
    role == "owner"
  end

  def admin?
    role == "admin"
  end

  def owner_or_admin?
    owner? || admin?
  end

  def permissions
    PERMISSIONS_BY_ROLE.fetch(role, [])
  end

  def has_permission?(permission)
    active? && account&.active? && permissions.include?(permission.to_sym)
  end

  private

  def set_default_role
    self.role ||= account&.default_membership_role
  end

  def individual_merchant_has_one_active_membership
    return unless active?
    return unless account&.individual_merchant?

    existing_membership = account.account_memberships.active
    existing_membership = existing_membership.where.not(id: id) if persisted?

    if existing_membership.exists?
      errors.add(:account, "can only have one active membership for an individual merchant")
    end
  end
end

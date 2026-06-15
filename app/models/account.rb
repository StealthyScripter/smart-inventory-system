class Account < ApplicationRecord
  ACCOUNT_TYPES = %w[customer individual_merchant enterprise_merchant].freeze
  STATUSES = %w[active suspended closed pending].freeze

  belongs_to :creator, class_name: "User", foreign_key: "created_by_id", optional: true, inverse_of: :created_accounts
  has_many :account_memberships, dependent: :destroy
  has_many :users, through: :account_memberships
  has_one :customer_profile, dependent: :destroy
  has_one :merchant_profile, dependent: :destroy

  validates :name, :account_type, :status, presence: true
  validates :account_type, inclusion: { in: ACCOUNT_TYPES }
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }
  scope :customers, -> { where(account_type: "customer") }
  scope :merchants, -> { where(account_type: %w[individual_merchant enterprise_merchant]) }
  scope :individual_merchants, -> { where(account_type: "individual_merchant") }
  scope :enterprise_merchants, -> { where(account_type: "enterprise_merchant") }

  def self.create_with_owner!(creator:, **attributes)
    transaction do
      account = create!(attributes.merge(creator: creator))
      account.add_member!(creator, role: "owner")
      account
    end
  end

  def add_member!(user, role: nil)
    account_memberships.create!(user: user, role: role || default_membership_role)
  end

  def customer?
    account_type == "customer"
  end

  def individual_merchant?
    account_type == "individual_merchant"
  end

  def enterprise_merchant?
    account_type == "enterprise_merchant"
  end

  def merchant?
    individual_merchant? || enterprise_merchant?
  end

  def active?
    status == "active"
  end

  def suspended?
    status == "suspended"
  end

  def default_membership_role
    return "employee" if enterprise_merchant? && account_memberships.exists?

    "owner"
  end
end

class Supplier < ApplicationRecord
  has_many :products, dependent: :nullify
  has_many :purchase_orders, dependent: :restrict_with_error
  has_many :supplier_users, dependent: :destroy
  has_many :users, through: :supplier_users
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :default_lead_time_days, presence: true, numericality: { greater_than: 0 }

  def average_rating
    reviews.published.average(:rating).to_f
  end
end

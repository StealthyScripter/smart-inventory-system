class AddAccountReferencesToMarketplaceRecords < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :account, foreign_key: true
    add_reference :service_listings, :account, foreign_key: true
    add_reference :order_items, :account, foreign_key: true
    add_reference :service_bookings, :account, foreign_key: true
    add_reference :conversations, :account, foreign_key: true
    add_reference :reviews, :account, foreign_key: true
    add_reference :notifications, :account, foreign_key: true
    add_reference :reports, :account, foreign_key: true
    add_reference :locations, :account, foreign_key: true
    add_reference :stock_levels, :account, foreign_key: true
    add_reference :stock_movements, :account, foreign_key: true
    add_reference :carts, :customer_account, foreign_key: { to_table: :accounts }
    add_reference :orders, :customer_account, foreign_key: { to_table: :accounts }
  end
end

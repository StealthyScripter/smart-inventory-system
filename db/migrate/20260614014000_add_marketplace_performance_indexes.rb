class AddMarketplacePerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :products, [:marketplace_status, :listing_scope, :supplier_id], name: "index_products_on_marketplace_discovery", if_not_exists: true
    add_index :products, [:category_id, :marketplace_status], name: "index_products_on_category_and_marketplace_status", if_not_exists: true
    add_index :service_listings, [:status, :service_category, :supplier_id], name: "index_services_on_discovery_fields", if_not_exists: true
    add_index :service_bookings, [:status, :scheduled_date], name: "index_service_bookings_on_status_and_scheduled_date", if_not_exists: true
    add_index :messages, [:sender_id, :read_at], name: "index_messages_on_sender_and_read_at", if_not_exists: true
    add_index :reviews, [:status, :rating], name: "index_reviews_on_status_and_rating", if_not_exists: true
  end
end

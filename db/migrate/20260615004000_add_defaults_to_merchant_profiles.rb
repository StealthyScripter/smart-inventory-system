class AddDefaultsToMerchantProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :merchant_profiles, :default_listing_status, :string, null: false, default: "draft"
    add_column :merchant_profiles, :default_inventory_policy, :string, null: false, default: "track_stock"
    add_column :merchant_profiles, :default_fulfillment_days, :integer, null: false, default: 3
  end
end

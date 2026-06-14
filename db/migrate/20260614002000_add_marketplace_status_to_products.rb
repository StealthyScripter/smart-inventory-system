class AddMarketplaceStatusToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :marketplace_status, :string, null: false, default: "draft"
    add_index :products, :marketplace_status
  end
end

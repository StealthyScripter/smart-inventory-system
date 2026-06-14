class AddListingScopeToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :listing_scope, :string, null: false, default: "both"
    add_index :products, :listing_scope
  end
end

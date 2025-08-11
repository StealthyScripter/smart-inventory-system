class CreateStockLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_levels do |t|
      t.references :product, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.integer :current_quantity, default: 0
      t.integer :reserved_quantity, default: 0

      t.timestamps
    end
    
    add_index :stock_levels, [:product_id, :location_id], unique: true
  end
end
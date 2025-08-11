class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.decimal :unit_cost, precision: 10, scale: 2
      t.decimal :selling_price, precision: 10, scale: 2
      t.integer :reorder_point, default: 10
      t.integer :lead_time_days, default: 7
      t.references :category, null: false, foreign_key: true
      t.references :supplier, null: true, foreign_key: true

      t.timestamps
    end
    
    add_index :products, :sku, unique: true
  end
end
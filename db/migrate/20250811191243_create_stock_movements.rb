class CreateStockMovements < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :source_location, null: true, foreign_key: { to_table: :locations }
      t.references :destination_location, null: true, foreign_key: { to_table: :locations }
      t.string :movement_type, null: false
      t.integer :quantity, null: false
      t.integer :reference_id
      t.string :reference_type
      t.references :user, null: false, foreign_key: true
      t.text :notes
      t.datetime :movement_date, null: false

      t.timestamps
    end
    
    add_index :stock_movements, [:reference_type, :reference_id]
  end
end
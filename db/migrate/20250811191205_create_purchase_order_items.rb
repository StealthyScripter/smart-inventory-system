class CreatePurchaseOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_cost, precision: 10, scale: 2
      t.decimal :total_cost, precision: 10, scale: 2

      t.timestamps
    end
  end
end
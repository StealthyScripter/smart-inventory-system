class CreatePurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_orders do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :status, default: 'pending'
      t.date :order_date, null: false
      t.date :expected_delivery_date
      t.decimal :total_amount, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :purchase_orders, :order_number, unique: true
  end
end

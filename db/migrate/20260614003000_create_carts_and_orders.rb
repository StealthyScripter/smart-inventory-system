class CreateCartsAndOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :carts, [:user_id, :status]

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_items, [:cart_id, :product_id], unique: true

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.string :status, null: false, default: "pending"
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: "0.0"
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, [:user_id, :status]

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false, default: "0.0"
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: "0.0"
      t.string :fulfillment_status, null: false, default: "pending"

      t.timestamps
    end

    add_index :order_items, [:supplier_id, :fulfillment_status]
  end
end

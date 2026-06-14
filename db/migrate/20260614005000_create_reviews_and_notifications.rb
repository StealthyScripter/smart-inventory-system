class CreateReviewsAndNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.references :order_item, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.string :status, null: false, default: "published"

      t.timestamps
    end

    add_index :reviews, [:user_id, :order_item_id], unique: true
    add_index :reviews, [:supplier_id, :status]
    add_index :reviews, [:product_id, :status]

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :title, null: false
      t.text :body
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [:user_id, :read_at]
  end
end

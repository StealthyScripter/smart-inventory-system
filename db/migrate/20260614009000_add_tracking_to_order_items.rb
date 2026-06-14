class AddTrackingToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :tracking_carrier, :string
    add_column :order_items, :tracking_number, :string
    add_column :order_items, :merchant_notes, :text
    add_column :order_items, :shipped_at, :datetime
    add_column :order_items, :delivered_at, :datetime

    add_index :order_items, :tracking_number
  end
end

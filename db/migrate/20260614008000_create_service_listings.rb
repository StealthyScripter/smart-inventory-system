class CreateServiceListings < ActiveRecord::Migration[8.0]
  def change
    create_table :service_listings do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :name, null: false
      t.string :service_category, null: false
      t.text :description
      t.decimal :starting_price, precision: 10, scale: 2
      t.string :image_url
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :service_listings, [:supplier_id, :status]
    add_index :service_listings, :service_category

    change_table :reviews do |t|
      t.references :service_listing, null: true, foreign_key: true
      t.change_null :product_id, true
      t.change_null :order_item_id, true
    end
  end
end

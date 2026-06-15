class CreateMarketplaceListings < ActiveRecord::Migration[8.0]
  def change
    create_table :marketplace_listings do |t|
      t.references :account, foreign_key: true
      t.references :product, foreign_key: true, index: { unique: true }
      t.references :service_listing, foreign_key: true, index: { unique: true }
      t.string :title, null: false
      t.text :public_description
      t.decimal :public_price, precision: 10, scale: 2
      t.decimal :sale_price, precision: 10, scale: 2
      t.string :status, null: false, default: "draft"
      t.string :visibility, null: false, default: "private"
      t.string :listing_type, null: false, default: "product"
      t.text :seo_keywords
      t.boolean :shipping_eligible, null: false, default: true

      t.timestamps
    end

    add_index :marketplace_listings, :status
    add_index :marketplace_listings, :visibility
    add_index :marketplace_listings, [:status, :visibility, :listing_type], name: "index_marketplace_listings_on_public_discovery"
  end
end

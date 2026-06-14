class AddRealWorldReadinessFields < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :barcode_value, :string
    add_column :products, :discarded_at, :datetime
    add_column :service_listings, :discarded_at, :datetime
    add_column :suppliers, :discarded_at, :datetime
    add_column :reviews, :discarded_at, :datetime

    add_index :products, :barcode_value, unique: true
    add_index :products, :discarded_at
    add_index :service_listings, :discarded_at
    add_index :suppliers, :discarded_at
    add_index :reviews, :discarded_at
  end
end

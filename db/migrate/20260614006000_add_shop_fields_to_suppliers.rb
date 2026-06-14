class AddShopFieldsToSuppliers < ActiveRecord::Migration[8.0]
  def change
    add_column :suppliers, :shop_slug, :string
    add_column :suppliers, :shop_status, :string, null: false, default: "draft"
    add_column :suppliers, :shop_description, :text
    add_column :suppliers, :shop_image_url, :string

    add_index :suppliers, :shop_slug, unique: true
    add_index :suppliers, :shop_status
  end
end

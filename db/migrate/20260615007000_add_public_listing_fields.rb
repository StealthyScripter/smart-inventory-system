class AddPublicListingFields < ActiveRecord::Migration[8.0]
  def change
    add_column :marketplace_listings, :availability, :string, null: false, default: "available"
    add_column :marketplace_listings, :search_tags, :text
    add_column :marketplace_listings, :featured_media_url, :string
    add_column :service_listings, :visibility, :string, null: false, default: "public"
  end
end

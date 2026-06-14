class AddSearchTagsToMarketplaceRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :search_tags, :text
    add_column :service_listings, :search_tags, :text
    add_column :suppliers, :search_tags, :text
  end
end

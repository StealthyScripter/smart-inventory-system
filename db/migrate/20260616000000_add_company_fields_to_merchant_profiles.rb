class AddCompanyFieldsToMerchantProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :merchant_profiles, :location, :string
    add_column :merchant_profiles, :company_size, :string
    add_column :merchant_profiles, :contact_information, :text
    add_column :merchant_profiles, :business_category, :string
    add_column :merchant_profiles, :permits_and_licenses, :text
    add_column :merchant_profiles, :controlled_goods_notes, :text
  end
end

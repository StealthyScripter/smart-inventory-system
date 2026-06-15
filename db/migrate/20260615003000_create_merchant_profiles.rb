class CreateMerchantProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :merchant_profiles do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.references :supplier, foreign_key: true, index: { unique: true }
      t.string :display_name, null: false
      t.text :description
      t.string :slug
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
    add_index :merchant_profiles, :slug, unique: true
    add_index :merchant_profiles, :status
  end
end

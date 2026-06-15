class CreateCustomerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_profiles do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.string :display_name
      t.text :preferences

      t.timestamps
    end
  end
end

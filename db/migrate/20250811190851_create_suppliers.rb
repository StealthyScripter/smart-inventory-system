class CreateSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :contact_email
      t.string :contact_phone
      t.text :address
      t.integer :default_lead_time_days, default: 7

      t.timestamps
    end
  end
end

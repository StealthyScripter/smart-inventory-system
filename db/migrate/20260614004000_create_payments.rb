class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider, null: false, default: "manual"
      t.string :provider_reference
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "USD"
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :payments, [:provider, :provider_reference], unique: true
    add_index :payments, :status

    create_table :webhook_events do |t|
      t.string :provider, null: false
      t.string :external_id, null: false
      t.string :event_type, null: false
      t.text :payload, null: false
      t.string :status, null: false, default: "received"

      t.timestamps
    end

    add_index :webhook_events, [:provider, :external_id], unique: true
  end
end

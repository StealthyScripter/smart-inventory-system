class CreateSupplierUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :supplier_users do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :supplier_users, [:supplier_id, :user_id], unique: true
  end
end

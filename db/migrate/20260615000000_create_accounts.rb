class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :account_type, null: false
      t.string :status, null: false, default: "active"
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :accounts, :account_type
    add_index :accounts, :status
  end
end

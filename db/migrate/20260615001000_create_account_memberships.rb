class CreateAccountMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :account_memberships do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :account_memberships, [:account_id, :user_id], unique: true
    add_index :account_memberships, [:account_id, :role]
    add_index :account_memberships, [:user_id, :active]
  end
end

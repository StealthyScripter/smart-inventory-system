class CreateConversationsAndMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :supplier, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.references :service_booking, null: true, foreign_key: true
      t.string :subject, null: false

      t.timestamps
    end

    add_index :conversations, [:customer_id, :supplier_id, :order_id, :service_booking_id], name: "index_conversations_on_participants_and_context"

    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, [:conversation_id, :read_at]
  end
end

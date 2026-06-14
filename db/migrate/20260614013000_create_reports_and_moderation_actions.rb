class CreateReportsAndModerationActions < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reportable, null: false, polymorphic: true
      t.string :reason, null: false
      t.text :details
      t.string :status, null: false, default: "open"

      t.timestamps
    end

    add_index :reports, [:reportable_type, :reportable_id, :status]
    add_index :reports, :status

    create_table :moderation_actions do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :moderatable, null: false, polymorphic: true
      t.string :action_name, null: false
      t.text :notes

      t.timestamps
    end

    add_index :moderation_actions, :action_name
  end
end

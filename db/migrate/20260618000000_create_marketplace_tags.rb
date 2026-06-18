class CreateMarketplaceTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :context, null: false, default: "category"
      t.string :display_name
      t.text :description
      t.boolean :marketplace_section, null: false, default: true
      t.integer :position, null: false, default: 100

      t.timestamps
    end

    add_index :tags, [:context, :slug], unique: true
    add_index :tags, [:marketplace_section, :position]

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :taggings, [:tag_id, :taggable_type, :taggable_id], unique: true
  end
end

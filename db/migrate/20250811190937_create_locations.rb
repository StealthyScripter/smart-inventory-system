class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.text :address
      t.references :manager, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

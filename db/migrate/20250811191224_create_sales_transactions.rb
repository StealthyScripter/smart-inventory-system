class CreateSalesTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :sales_transactions do |t|
      t.references :product, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :customer_name
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2
      t.decimal :total_amount, precision: 10, scale: 2
      t.datetime :transaction_date, null: false

      t.timestamps
    end
  end
end

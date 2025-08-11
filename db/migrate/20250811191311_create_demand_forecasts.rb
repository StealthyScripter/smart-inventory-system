class CreateDemandForecasts < ActiveRecord::Migration[7.0]
  def change
    create_table :demand_forecasts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.date :forecast_date, null: false
      t.string :period_type, null: false
      t.decimal :predicted_demand, precision: 10, scale: 2
      t.decimal :confidence_score, precision: 5, scale: 4

      t.timestamps
    end

    add_index :demand_forecasts, [ :product_id, :location_id, :forecast_date, :period_type ],
              unique: true, name: 'index_demand_forecasts_unique'
  end
end

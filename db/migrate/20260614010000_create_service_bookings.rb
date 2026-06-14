class CreateServiceBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :service_bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.string :booking_number, null: false
      t.string :status, null: false, default: "requested"
      t.date :scheduled_date
      t.time :scheduled_time
      t.integer :duration_minutes
      t.text :notes

      t.timestamps
    end

    add_index :service_bookings, :booking_number, unique: true
    add_index :service_bookings, [:supplier_id, :status]
    add_index :service_bookings, [:user_id, :status]

    create_table :service_booking_items do |t|
      t.references :service_booking, null: false, foreign_key: true
      t.references :service_listing, null: false, foreign_key: true
      t.decimal :quoted_price, precision: 10, scale: 2

      t.timestamps
    end

    create_table :availability_slots do |t|
      t.references :supplier, null: false, foreign_key: true
      t.date :available_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :booked, null: false, default: false

      t.timestamps
    end

    add_index :availability_slots, [:supplier_id, :available_date]
  end
end

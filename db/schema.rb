# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_11_191311) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "demand_forecasts", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "location_id", null: false
    t.date "forecast_date", null: false
    t.string "period_type", null: false
    t.decimal "predicted_demand", precision: 10, scale: 2
    t.decimal "confidence_score", precision: 5, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_demand_forecasts_on_location_id"
    t.index ["product_id", "location_id", "forecast_date", "period_type"], name: "index_demand_forecasts_unique", unique: true
    t.index ["product_id"], name: "index_demand_forecasts_on_product_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.integer "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_locations_on_manager_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "sku", null: false
    t.text "description"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "selling_price", precision: 10, scale: 2
    t.integer "reorder_point", default: 10
    t.integer "lead_time_days", default: 7
    t.integer "category_id", null: false
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.integer "purchase_order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_cost", precision: 10, scale: 2
    t.decimal "total_cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer "supplier_id", null: false
    t.integer "user_id", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending"
    t.date "order_date", null: false
    t.date "expected_delivery_date"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_number"], name: "index_purchase_orders_on_order_number", unique: true
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "sales_transactions", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "location_id", null: false
    t.integer "user_id", null: false
    t.string "customer_name"
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "transaction_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_sales_transactions_on_location_id"
    t.index ["product_id"], name: "index_sales_transactions_on_product_id"
    t.index ["user_id"], name: "index_sales_transactions_on_user_id"
  end

  create_table "stock_levels", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "location_id", null: false
    t.integer "current_quantity", default: 0
    t.integer "reserved_quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_stock_levels_on_location_id"
    t.index ["product_id", "location_id"], name: "index_stock_levels_on_product_id_and_location_id", unique: true
    t.index ["product_id"], name: "index_stock_levels_on_product_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "source_location_id"
    t.integer "destination_location_id"
    t.string "movement_type", null: false
    t.integer "quantity", null: false
    t.integer "reference_id"
    t.string "reference_type"
    t.integer "user_id", null: false
    t.text "notes"
    t.datetime "movement_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_location_id"], name: "index_stock_movements_on_destination_location_id"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["reference_type", "reference_id"], name: "index_stock_movements_on_reference_type_and_reference_id"
    t.index ["source_location_id"], name: "index_stock_movements_on_source_location_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact_email"
    t.string "contact_phone"
    t.text "address"
    t.integer "default_lead_time_days", default: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "role", null: false
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["location_id"], name: "index_users_on_location_id"
  end

  add_foreign_key "demand_forecasts", "locations"
  add_foreign_key "demand_forecasts", "products"
  add_foreign_key "locations", "users", column: "manager_id"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "suppliers"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "sales_transactions", "locations"
  add_foreign_key "sales_transactions", "products"
  add_foreign_key "sales_transactions", "users"
  add_foreign_key "stock_levels", "locations"
  add_foreign_key "stock_levels", "products"
  add_foreign_key "stock_movements", "locations", column: "destination_location_id"
  add_foreign_key "stock_movements", "locations", column: "source_location_id"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "users", "locations"
end

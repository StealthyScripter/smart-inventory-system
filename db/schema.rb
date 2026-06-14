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

ActiveRecord::Schema[8.1].define(version: 2026_06_14_005000) do
  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.integer "actor_id"
    t.integer "auditable_id", null: false
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["actor_id"], name: "index_audit_logs_on_actor_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id"], name: "index_cart_items_on_cart_id_and_product_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "status"], name: "index_carts_on_user_id_and_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "demand_forecasts", force: :cascade do |t|
    t.decimal "confidence_score", precision: 5, scale: 4
    t.datetime "created_at", null: false
    t.date "forecast_date", null: false
    t.integer "location_id", null: false
    t.string "period_type", null: false
    t.decimal "predicted_demand", precision: 10, scale: 2
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_demand_forecasts_on_location_id"
    t.index ["product_id", "location_id", "forecast_date", "period_type"], name: "index_demand_forecasts_unique", unique: true
    t.index ["product_id"], name: "index_demand_forecasts_on_product_id"
  end

  create_table "locations", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.integer "manager_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_locations_on_manager_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fulfillment_status", default: "pending", null: false
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "supplier_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["supplier_id", "fulfillment_status"], name: "index_order_items_on_supplier_id_and_fulfillment_status"
    t.index ["supplier_id"], name: "index_order_items_on_supplier_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending", null: false
    t.datetime "submitted_at"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["user_id", "status"], name: "index_orders_on_user_id_and_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.integer "order_id", null: false
    t.string "provider", default: "manual", null: false
    t.string "provider_reference"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["provider", "provider_reference"], name: "index_payments_on_provider_and_provider_reference", unique: true
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "lead_time_days", default: 7
    t.string "marketplace_status", default: "draft", null: false
    t.string "name", null: false
    t.integer "reorder_point", default: 10
    t.decimal "selling_price", precision: 10, scale: 2
    t.string "sku", null: false
    t.integer "supplier_id"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["marketplace_status"], name: "index_products_on_marketplace_status"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "purchase_order_id", null: false
    t.integer "quantity", null: false
    t.decimal "total_cost", precision: 10, scale: 2
    t.decimal "unit_cost", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_order_items_on_product_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expected_delivery_date"
    t.date "order_date", null: false
    t.string "order_number", null: false
    t.string "status", default: "pending"
    t.integer "supplier_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["order_number"], name: "index_purchase_orders_on_order_number", unique: true
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
    t.index ["user_id"], name: "index_purchase_orders_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "order_item_id", null: false
    t.integer "product_id", null: false
    t.integer "rating", null: false
    t.string "status", default: "published", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["order_item_id"], name: "index_reviews_on_order_item_id"
    t.index ["product_id", "status"], name: "index_reviews_on_product_id_and_status"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["supplier_id", "status"], name: "index_reviews_on_supplier_id_and_status"
    t.index ["supplier_id"], name: "index_reviews_on_supplier_id"
    t.index ["user_id", "order_item_id"], name: "index_reviews_on_user_id_and_order_item_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "sales_transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.integer "location_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.datetime "transaction_date", null: false
    t.decimal "unit_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["location_id"], name: "index_sales_transactions_on_location_id"
    t.index ["product_id"], name: "index_sales_transactions_on_product_id"
    t.index ["user_id"], name: "index_sales_transactions_on_user_id"
  end

  create_table "stock_levels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "current_quantity", default: 0
    t.integer "location_id", null: false
    t.integer "product_id", null: false
    t.integer "reserved_quantity", default: 0
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_stock_levels_on_location_id"
    t.index ["product_id", "location_id"], name: "index_stock_levels_on_product_id_and_location_id", unique: true
    t.index ["product_id"], name: "index_stock_levels_on_product_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "destination_location_id"
    t.datetime "movement_date", null: false
    t.string "movement_type", null: false
    t.text "notes"
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "reference_id"
    t.string "reference_type"
    t.integer "source_location_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["destination_location_id"], name: "index_stock_movements_on_destination_location_id"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["reference_type", "reference_id"], name: "index_stock_movements_on_reference_type_and_reference_id"
    t.index ["source_location_id"], name: "index_stock_movements_on_source_location_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "supplier_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["supplier_id", "user_id"], name: "index_supplier_users_on_supplier_id_and_user_id", unique: true
    t.index ["supplier_id"], name: "index_supplier_users_on_supplier_id"
    t.index ["user_id"], name: "index_supplier_users_on_user_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.text "address"
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.integer "default_lead_time_days", default: 7
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "location_id"
    t.string "password_digest"
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["location_id"], name: "index_users_on_location_id"
  end

  create_table "webhook_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "external_id", null: false
    t.text "payload", null: false
    t.string "provider", null: false
    t.string "status", default: "received", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "external_id"], name: "index_webhook_events_on_provider_and_external_id", unique: true
  end

  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "demand_forecasts", "locations"
  add_foreign_key "demand_forecasts", "products"
  add_foreign_key "locations", "users", column: "manager_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "order_items", "suppliers"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "suppliers"
  add_foreign_key "purchase_order_items", "products"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "suppliers"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "reviews", "order_items"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "suppliers"
  add_foreign_key "reviews", "users"
  add_foreign_key "sales_transactions", "locations"
  add_foreign_key "sales_transactions", "products"
  add_foreign_key "sales_transactions", "users"
  add_foreign_key "stock_levels", "locations"
  add_foreign_key "stock_levels", "products"
  add_foreign_key "stock_movements", "locations", column: "destination_location_id"
  add_foreign_key "stock_movements", "locations", column: "source_location_id"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "supplier_users", "suppliers"
  add_foreign_key "supplier_users", "users"
  add_foreign_key "users", "locations"
end

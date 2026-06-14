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

ActiveRecord::Schema[8.1].define(version: 2026_06_14_016000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    t.index ["blob_id"], name: "index_active_storage_variant_records_on_blob_id"
  end

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

  create_table "availability_slots", force: :cascade do |t|
    t.date "available_date", null: false
    t.boolean "booked", default: false, null: false
    t.datetime "created_at", null: false
    t.time "end_time", null: false
    t.time "start_time", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id", "available_date"], name: "index_availability_slots_on_supplier_id_and_available_date"
    t.index ["supplier_id"], name: "index_availability_slots_on_supplier_id"
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

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.integer "order_id"
    t.integer "service_booking_id"
    t.string "subject", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "supplier_id", "order_id", "service_booking_id"], name: "index_conversations_on_participants_and_context"
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["order_id"], name: "index_conversations_on_order_id"
    t.index ["service_booking_id"], name: "index_conversations_on_service_booking_id"
    t.index ["supplier_id"], name: "index_conversations_on_supplier_id"
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

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "read_at"], name: "index_messages_on_conversation_id_and_read_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id", "read_at"], name: "index_messages_on_sender_and_read_at"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "moderation_actions", force: :cascade do |t|
    t.string "action_name", null: false
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.integer "moderatable_id", null: false
    t.string "moderatable_type", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["action_name"], name: "index_moderation_actions_on_action_name"
    t.index ["actor_id"], name: "index_moderation_actions_on_actor_id"
    t.index ["moderatable_type", "moderatable_id"], name: "index_moderation_actions_on_moderatable"
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
    t.datetime "delivered_at"
    t.string "fulfillment_status", default: "pending", null: false
    t.text "merchant_notes"
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.datetime "shipped_at"
    t.integer "supplier_id", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.string "tracking_carrier"
    t.string "tracking_number"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["supplier_id", "fulfillment_status"], name: "index_order_items_on_supplier_id_and_fulfillment_status"
    t.index ["supplier_id"], name: "index_order_items_on_supplier_id"
    t.index ["tracking_number"], name: "index_order_items_on_tracking_number"
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
    t.string "barcode_value"
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.integer "lead_time_days", default: 7
    t.string "listing_scope", default: "both", null: false
    t.string "marketplace_status", default: "draft", null: false
    t.string "name", null: false
    t.integer "reorder_point", default: 10
    t.text "search_tags"
    t.decimal "selling_price", precision: 10, scale: 2
    t.string "sku", null: false
    t.integer "supplier_id"
    t.decimal "unit_cost", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["barcode_value"], name: "index_products_on_barcode_value", unique: true
    t.index ["category_id", "marketplace_status"], name: "index_products_on_category_and_marketplace_status"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["listing_scope"], name: "index_products_on_listing_scope"
    t.index ["marketplace_status", "listing_scope", "supplier_id"], name: "index_products_on_marketplace_discovery"
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

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details"
    t.string "reason", null: false
    t.integer "reportable_id", null: false
    t.string "reportable_type", null: false
    t.integer "reporter_id", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id", "status"], name: "index_reports_on_reportable_type_and_reportable_id_and_status"
    t.index ["reportable_type", "reportable_id"], name: "index_reports_on_reportable"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.integer "order_item_id"
    t.integer "product_id"
    t.integer "rating", null: false
    t.integer "service_listing_id"
    t.string "status", default: "published", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["discarded_at"], name: "index_reviews_on_discarded_at"
    t.index ["order_item_id"], name: "index_reviews_on_order_item_id"
    t.index ["product_id", "status"], name: "index_reviews_on_product_id_and_status"
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["service_listing_id"], name: "index_reviews_on_service_listing_id"
    t.index ["status", "rating"], name: "index_reviews_on_status_and_rating"
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

  create_table "service_booking_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "quoted_price", precision: 10, scale: 2
    t.integer "service_booking_id", null: false
    t.integer "service_listing_id", null: false
    t.datetime "updated_at", null: false
    t.index ["service_booking_id"], name: "index_service_booking_items_on_service_booking_id"
    t.index ["service_listing_id"], name: "index_service_booking_items_on_service_listing_id"
  end

  create_table "service_bookings", force: :cascade do |t|
    t.string "booking_number", null: false
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.text "notes"
    t.date "scheduled_date"
    t.time "scheduled_time"
    t.string "status", default: "requested", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["booking_number"], name: "index_service_bookings_on_booking_number", unique: true
    t.index ["status", "scheduled_date"], name: "index_service_bookings_on_status_and_scheduled_date"
    t.index ["supplier_id", "status"], name: "index_service_bookings_on_supplier_id_and_status"
    t.index ["supplier_id"], name: "index_service_bookings_on_supplier_id"
    t.index ["user_id", "status"], name: "index_service_bookings_on_user_id_and_status"
    t.index ["user_id"], name: "index_service_bookings_on_user_id"
  end

  create_table "service_listings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "image_url"
    t.string "name", null: false
    t.text "search_tags"
    t.string "service_category", null: false
    t.decimal "starting_price", precision: 10, scale: 2
    t.string "status", default: "draft", null: false
    t.integer "supplier_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_service_listings_on_discarded_at"
    t.index ["service_category"], name: "index_service_listings_on_service_category"
    t.index ["status", "service_category", "supplier_id"], name: "index_services_on_discovery_fields"
    t.index ["supplier_id", "status"], name: "index_service_listings_on_supplier_id_and_status"
    t.index ["supplier_id"], name: "index_service_listings_on_supplier_id"
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
    t.datetime "discarded_at"
    t.string "name", null: false
    t.text "search_tags"
    t.text "shop_description"
    t.string "shop_image_url"
    t.string "shop_slug"
    t.string "shop_status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_suppliers_on_discarded_at"
    t.index ["shop_slug"], name: "index_suppliers_on_shop_slug", unique: true
    t.index ["shop_status"], name: "index_suppliers_on_shop_status"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users", column: "actor_id"
  add_foreign_key "availability_slots", "suppliers"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "conversations", "orders"
  add_foreign_key "conversations", "service_bookings"
  add_foreign_key "conversations", "suppliers"
  add_foreign_key "conversations", "users", column: "customer_id"
  add_foreign_key "demand_forecasts", "locations"
  add_foreign_key "demand_forecasts", "products"
  add_foreign_key "locations", "users", column: "manager_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "moderation_actions", "users", column: "actor_id"
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
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reviews", "order_items"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "service_listings"
  add_foreign_key "reviews", "suppliers"
  add_foreign_key "reviews", "users"
  add_foreign_key "sales_transactions", "locations"
  add_foreign_key "sales_transactions", "products"
  add_foreign_key "sales_transactions", "users"
  add_foreign_key "service_booking_items", "service_bookings"
  add_foreign_key "service_booking_items", "service_listings"
  add_foreign_key "service_bookings", "suppliers"
  add_foreign_key "service_bookings", "users"
  add_foreign_key "service_listings", "suppliers"
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

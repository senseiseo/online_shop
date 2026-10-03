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

ActiveRecord::Schema[8.1].define(version: 2026_10_03_003000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id"], name: "index_cart_items_on_cart_id_and_product_id", unique: true
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.check_constraint "quantity > 0", name: "cart_items_positive_quantity"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "visitor_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "updated_at"], name: "index_carts_on_status_and_updated_at"
    t.index ["visitor_id"], name: "index_carts_on_visitor_id"
    t.index ["visitor_id"], name: "index_carts_one_active_per_visitor", unique: true, where: "status = 0"
    t.check_constraint "status IN (0, 1, 2)", name: "carts_valid_status"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published", "position"], name: "index_categories_on_published_and_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.check_constraint "position >= 0", name: "categories_position_nonnegative"
  end

  create_table "inquiries", force: :cascade do |t|
    t.integer "visitor_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.text "message", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "created_at"], name: "index_inquiries_on_status_and_created_at"
    t.index ["visitor_id"], name: "index_inquiries_on_visitor_id"
    t.check_constraint "status IN (0, 1, 2, 3)", name: "inquiries_valid_status"
    t.check_constraint "trim(COALESCE(phone, '')) <> '' OR trim(COALESCE(email, '')) <> ''", name: "inquiries_contact_present"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.string "product_name", null: false
    t.integer "unit_price_cents", null: false
    t.integer "quantity", null: false
    t.integer "total_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.check_constraint "quantity > 0", name: "order_items_positive_quantity"
    t.check_constraint "total_price_cents >= 0", name: "order_items_total_price_cents_nonnegative"
    t.check_constraint "unit_price_cents >= 0", name: "order_items_unit_price_cents_nonnegative"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "visitor_id", null: false
    t.integer "cart_id", null: false
    t.string "number", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.text "comment"
    t.integer "status", default: 0, null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.integer "total_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_orders_on_cart_id", unique: true
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["status", "created_at"], name: "index_orders_on_status_and_created_at"
    t.index ["visitor_id"], name: "index_orders_on_visitor_id"
    t.check_constraint "payment_method IN (0, 1, 2)", name: "orders_valid_payment_method"
    t.check_constraint "payment_status IN (0, 1)", name: "orders_valid_payment_status"
    t.check_constraint "status IN (0, 1, 2, 3, 4, 5)", name: "orders_valid_status"
    t.check_constraint "total_price_cents >= 0", name: "orders_total_price_cents_nonnegative"
    t.check_constraint "trim(COALESCE(phone, '')) <> '' OR trim(COALESCE(email, '')) <> ''", name: "orders_contact_present"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "excerpt"
    t.boolean "published", default: false, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published", "published_at"], name: "index_posts_on_published_and_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "short_description"
    t.integer "price_cents", null: false
    t.integer "old_price_cents"
    t.boolean "published", default: false, null: false
    t.boolean "featured", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["published", "featured", "position"], name: "index_products_on_published_and_featured_and_position"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.check_constraint "old_price_cents IS NULL OR old_price_cents >= 0", name: "products_old_price_cents_nonnegative"
    t.check_constraint "position >= 0", name: "products_position_nonnegative"
    t.check_constraint "price_cents >= 0", name: "products_price_cents_nonnegative"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "visitors", force: :cascade do |t|
    t.string "token", null: false
    t.string "name"
    t.string "phone"
    t.string "email"
    t.datetime "first_seen_at", null: false
    t.datetime "last_seen_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_visitors_on_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "visitors"
  add_foreign_key "inquiries", "visitors"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "carts"
  add_foreign_key "orders", "visitors"
  add_foreign_key "products", "categories"
  add_foreign_key "sessions", "users"
end

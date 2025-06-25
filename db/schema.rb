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

ActiveRecord::Schema[7.1].define(version: 4) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "serial_number"
    t.string "category", null: false
    t.text "description"
    t.string "qr_code", null: false
    t.string "qr_code_url"
    t.string "status", default: "stokta"
    t.decimal "value", precision: 10, scale: 2
    t.string "brand"
    t.string "model"
    t.date "purchase_date"
    t.date "warranty_date"
    t.bigint "warehouse_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand"], name: "index_items_on_brand"
    t.index ["category"], name: "index_items_on_category"
    t.index ["name"], name: "index_items_on_name"
    t.index ["qr_code"], name: "index_items_on_qr_code", unique: true
    t.index ["serial_number"], name: "index_items_on_serial_number"
    t.index ["status"], name: "index_items_on_status"
    t.index ["warehouse_id"], name: "index_items_on_warehouse_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "action_type", null: false
    t.text "destination"
    t.text "notes"
    t.datetime "return_date"
    t.datetime "actual_return_date"
    t.string "status", default: "active"
    t.text "checkout_reason"
    t.text "checkin_notes"
    t.bigint "item_id", null: false
    t.bigint "user_id", null: false
    t.bigint "warehouse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_transactions_on_action_type"
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["item_id", "status"], name: "index_transactions_on_item_id_and_status"
    t.index ["item_id"], name: "index_transactions_on_item_id"
    t.index ["return_date"], name: "index_transactions_on_return_date"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["user_id", "created_at"], name: "index_transactions_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["warehouse_id"], name: "index_transactions_on_warehouse_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "role", default: "staff", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.text "location", null: false
    t.string "qr_code", null: false
    t.string "qr_code_url"
    t.text "description"
    t.decimal "capacity", precision: 10, scale: 2
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_warehouses_on_name"
    t.index ["qr_code"], name: "index_warehouses_on_qr_code", unique: true
    t.index ["status"], name: "index_warehouses_on_status"
  end

  add_foreign_key "items", "warehouses"
  add_foreign_key "transactions", "items"
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "warehouses"
end

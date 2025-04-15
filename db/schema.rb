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

ActiveRecord::Schema[8.0].define(version: 2025_04_14_071129) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bidding_fees", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "user_id", null: false
    t.bigint "bid_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_id"], name: "index_bidding_fees_on_bid_id"
    t.index ["user_id"], name: "index_bidding_fees_on_user_id"
  end

  create_table "bids", force: :cascade do |t|
    t.decimal "amount"
    t.bigint "user_id", null: false
    t.bigint "plate_number_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plate_number_id"], name: "index_bids_on_plate_number_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.string "status"
    t.bigint "user_id", null: false
    t.bigint "plate_number_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plate_number_id"], name: "index_payments_on_plate_number_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "plate_numbers", force: :cascade do |t|
    t.string "number"
    t.string "status"
    t.string "category"
    t.decimal "starting_price"
    t.decimal "current_price"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sale_type", default: "auction"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bidding_fee_paid", default: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bidding_fees", "bids"
  add_foreign_key "bidding_fees", "users"
  add_foreign_key "bids", "plate_numbers"
  add_foreign_key "bids", "users"
  add_foreign_key "payments", "plate_numbers"
  add_foreign_key "payments", "users"
end

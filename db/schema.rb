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

ActiveRecord::Schema[7.1].define(version: 2025_11_11_200508) do
  create_table "access_points", force: :cascade do |t|
    t.integer "client_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "access_points_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id", null: false
    t.bigint "access_point_id", null: false
    t.index ["access_point_id"], name: "index_access_points_locations_on_access_point_id"
    t.index ["location_id", "access_point_id"], name: "index_access_points_locations_on_location_id_and_access_point_id", unique: true
    t.index ["location_id"], name: "index_access_points_locations_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "url"
    t.text "comment"
    t.text "comment_two"
    t.string "summary"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "primary_location_id"
    t.boolean "primary", default: false
    t.boolean "front_page", default: false, null: false
    t.string "short_note"
    t.text "short_note_url"
    t.boolean "suppress_display", default: false
    t.integer "wifi_connections_baseline"
    t.index ["code"], name: "index_locations_on_code"
    t.index ["front_page"], name: "index_locations_on_front_page"
    t.index ["primary"], name: "index_locations_on_primary"
    t.index ["primary_location_id"], name: "index_locations_on_primary_location_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "user_id"
    t.string "role", null: false
    t.string "subject_class"
    t.integer "subject_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.date "date"
    t.datetime "open", precision: nil
    t.datetime "close", precision: nil
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "tbd", default: false, null: false
    t.boolean "closed", default: false, null: false
    t.string "note"
    t.integer "location_id"
    t.index ["close"], name: "index_timetables_on_close"
    t.index ["date"], name: "index_timetables_on_date"
    t.index ["location_id", "date"], name: "index_timetables_on_location_id_and_date", unique: true
    t.index ["location_id"], name: "index_timetables_on_location_id"
    t.index ["open"], name: "index_timetables_on_open"
  end

  create_table "users", force: :cascade do |t|
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uid"
    t.string "email", default: "", null: false
    t.string "name"
    t.index ["uid"], name: "index_users_on_uid"
  end

  add_foreign_key "locations", "locations", column: "primary_location_id"
  add_foreign_key "timetables", "locations"
end

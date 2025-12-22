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

ActiveRecord::Schema[8.1].define(version: 2024_07_25_171021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "alma_orangelight_call_numbers", id: :serial, force: :cascade do |t|
    t.text "author"
    t.text "bibid"
    t.text "date"
    t.string "dir"
    t.string "holding_id"
    t.text "label"
    t.string "location"
    t.text "scheme"
    t.text "sort"
    t.text "title"
    t.index ["label"], name: "index_alma_orangelight_call_numbers_on_label"
    t.index ["sort"], name: "index_alma_orangelight_call_numbers_on_sort"
  end

  create_table "alma_orangelight_name_titles", id: :serial, force: :cascade do |t|
    t.integer "count"
    t.string "dir"
    t.text "label"
    t.text "sort"
    t.index ["sort"], name: "index_alma_orangelight_name_titles_on_sort"
  end

  create_table "alma_orangelight_names", id: :serial, force: :cascade do |t|
    t.integer "count"
    t.string "dir"
    t.text "label"
    t.text "sort"
    t.index ["sort"], name: "index_alma_orangelight_names_on_sort"
  end

  create_table "alma_orangelight_subjects", id: :serial, force: :cascade do |t|
    t.integer "count"
    t.string "dir"
    t.text "label"
    t.text "sort"
    t.string "vocabulary"
    t.index ["sort"], name: "index_alma_orangelight_subjects_on_sort"
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "text"
    t.datetime "updated_at", null: false
  end

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "document_id"
    t.string "document_type"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.integer "user_id", null: false
    t.string "user_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "flipflop_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.datetime "expiration_time", precision: nil
    t.string "service", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_oauth_tokens_on_endpoint", unique: true
    t.index ["service"], name: "index_oauth_tokens_on_service", unique: true
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "query_params"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "guest", default: false
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "provider"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.string "username"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "bookmarks", "users", on_delete: :cascade
end

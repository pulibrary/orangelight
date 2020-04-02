# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200402142258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "document_type"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "hathi_pul_matches", force: :cascade do |t|
    t.string "oclc"
    t.string "pul_id"
    t.string "item_type"
    t.string "access"
    t.string "rights"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orangelight_call_numbers", id: :serial, force: :cascade do |t|
    t.text "label"
    t.string "dir"
    t.text "scheme"
    t.text "sort"
    t.text "title"
    t.text "author"
    t.text "date"
    t.text "bibid"
    t.string "holding_id"
    t.string "location"
    t.index ["label"], name: "index_orangelight_call_numbers_on_label"
    t.index ["sort"], name: "index_orangelight_call_numbers_on_sort"
  end

  create_table "orangelight_name_titles", id: :serial, force: :cascade do |t|
    t.text "label"
    t.integer "count"
    t.text "sort"
    t.string "dir"
    t.index ["sort"], name: "index_orangelight_name_titles_on_sort"
  end

  create_table "orangelight_names", id: :serial, force: :cascade do |t|
    t.text "label"
    t.integer "count"
    t.text "sort"
    t.string "dir"
    t.index ["sort"], name: "index_orangelight_names_on_sort"
  end

  create_table "orangelight_subjects", id: :serial, force: :cascade do |t|
    t.text "label"
    t.integer "count"
    t.text "sort"
    t.string "dir"
    t.index ["sort"], name: "index_orangelight_subjects_on_sort"
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.text "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "provider"
    t.string "uid"
    t.string "username"
    t.boolean "guest", default: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

end

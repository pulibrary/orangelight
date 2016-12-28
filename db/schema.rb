# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161222150444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blacklight_folders_folder_items", force: :cascade do |t|
    t.integer  "folder_id",   null: false
    t.integer  "bookmark_id", null: false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklight_folders_folder_items", ["bookmark_id"], name: "index_blacklight_folders_folder_items_on_bookmark_id", using: :btree
  add_index "blacklight_folders_folder_items", ["folder_id"], name: "index_blacklight_folders_folder_items_on_folder_id", using: :btree

  create_table "blacklight_folders_folders", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id",                       null: false
    t.string   "user_type",                     null: false
    t.string   "visibility"
    t.integer  "number_of_members", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blacklight_folders_folders", ["user_type", "user_id"], name: "index_blacklight_folders_folders_on_user_type_and_user_id", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "orangelight_call_numbers", force: :cascade do |t|
    t.text   "label"
    t.string "dir"
    t.text   "scheme"
    t.text   "sort"
    t.text   "title"
    t.text   "author"
    t.text   "date"
    t.text   "bibid"
    t.string "holding_id"
    t.string "location"
  end

  add_index "orangelight_call_numbers", ["sort"], name: "index_orangelight_call_numbers_on_sort", using: :btree

  create_table "orangelight_names", force: :cascade do |t|
    t.text    "label"
    t.integer "count"
    t.text    "sort"
    t.string  "dir"
  end

  add_index "orangelight_names", ["sort"], name: "index_orangelight_names_on_sort", using: :btree

  create_table "orangelight_subjects", force: :cascade do |t|
    t.text    "label"
    t.integer "count"
    t.text    "sort"
    t.string  "dir"
  end

  add_index "orangelight_subjects", ["sort"], name: "index_orangelight_subjects_on_sort", using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "username"
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end

# frozen_string_literal: true

class AlmaBrowseTables < ActiveRecord::Migration[5.2]
  def change
    create_table "alma_orangelight_call_numbers", id: :serial, force: :cascade do |t|
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
      t.index ["label"], name: "index_alma_orangelight_call_numbers_on_label"
      t.index ["sort"], name: "index_alma_orangelight_call_numbers_on_sort"
    end

    create_table "alma_orangelight_name_titles", id: :serial, force: :cascade do |t|
      t.text "label"
      t.integer "count"
      t.text "sort"
      t.string "dir"
      t.index ["sort"], name: "index_alma_orangelight_name_titles_on_sort"
    end

    create_table "alma_orangelight_names", id: :serial, force: :cascade do |t|
      t.text "label"
      t.integer "count"
      t.text "sort"
      t.string "dir"
      t.index ["sort"], name: "index_alma_orangelight_names_on_sort"
    end

    create_table "alma_orangelight_subjects", id: :serial, force: :cascade do |t|
      t.text "label"
      t.integer "count"
      t.text "sort"
      t.string "dir"
      t.index ["sort"], name: "index_alma_orangelight_subjects_on_sort"
    end
  end
end

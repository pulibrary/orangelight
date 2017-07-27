class CreateOrangelightNameTitles < ActiveRecord::Migration[4.2]
  def change
    create_table :orangelight_name_titles do |t|
      t.text :label
      t.integer :count
      t.text :sort, index: true
      t.string :dir
    end
  end
end

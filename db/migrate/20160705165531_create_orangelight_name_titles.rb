class CreateOrangelightNameTitles < ActiveRecord::Migration
  def change
    create_table :orangelight_name_titles do |t|
      t.text :label
      t.integer :count
      t.text :sort
      t.string :dir
    end
    add_index :orangelight_name_titles, :sort
  end
end

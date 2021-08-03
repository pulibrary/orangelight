class DropBrowseTables < ActiveRecord::Migration[5.2]
  def change
    drop_table "orangelight_call_numbers"
    drop_table "orangelight_name_titles"
    drop_table "orangelight_names"
    drop_table "orangelight_subjects"
  end
end

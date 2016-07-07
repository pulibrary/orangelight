class ModifyBrowseColumns < ActiveRecord::Migration
  def up
    change_column :orangelight_call_numbers, :label, :text
    change_column :orangelight_call_numbers, :scheme, :text
    change_column :orangelight_call_numbers, :sort, :text
    add_index :orangelight_names, :sort
    add_index :orangelight_subjects, :sort
    add_index :orangelight_call_numbers, :sort
  end
 
  def down
    remove_index :orangelight_call_numbers, :sort
    remove_index :orangelight_subjects, :sort
    remove_index :orangelight_names, :sort
    change_column :orangelight_call_numbers, :sort, :string
    change_column :orangelight_call_numbers, :scheme, :string
    change_column :orangelight_call_numbers, :label, :string
  end
end

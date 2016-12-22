class ChangeCallNumberToText < ActiveRecord::Migration
  def up
    change_column :orangelight_call_numbers, :label, :text
    change_column :orangelight_call_numbers, :sort, :text
    change_column :orangelight_call_numbers, :scheme, :text
    change_column :orangelight_call_numbers, :bibid, :text
  end

  def down
    change_column :orangelight_call_numbers, :label, :string
    change_column :orangelight_call_numbers, :sort, :string
    change_column :orangelight_call_numbers, :scheme, :string
    change_column :orangelight_call_numbers, :bibid, :string
  end
end

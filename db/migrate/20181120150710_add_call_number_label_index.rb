class AddCallNumberLabelIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :orangelight_call_numbers, :label
  end
end

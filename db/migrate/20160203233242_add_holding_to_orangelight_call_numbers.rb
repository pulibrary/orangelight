class AddHoldingToOrangelightCallNumbers < ActiveRecord::Migration[4.2]
  def change
    add_column :orangelight_call_numbers, :holding_id, :string
    add_column :orangelight_call_numbers, :location, :string
  end
end

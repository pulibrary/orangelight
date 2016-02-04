class AddHoldingToOrangelightCallNumbers < ActiveRecord::Migration
  def change
    add_column :orangelight_call_numbers, :holding_id, :string
    add_column :orangelight_call_numbers, :location, :string
  end
end

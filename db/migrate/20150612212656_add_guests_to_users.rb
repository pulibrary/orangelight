class AddGuestsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :guest, :boolean, default: false
  end
end

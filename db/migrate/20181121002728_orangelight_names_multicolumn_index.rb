class OrangelightNamesMulticolumnIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :orangelight_names, [:id, :sort]
  end
end

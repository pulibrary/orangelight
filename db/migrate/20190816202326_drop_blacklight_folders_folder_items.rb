class DropBlacklightFoldersFolderItems < ActiveRecord::Migration[5.1]
  def change
    drop_table :blacklight_folders_folder_items do |t|
      t.references :folder, null: false, index: true
      t.references :bookmark, null: false, index: true
      t.integer :position
      t.timestamps
    end
  end
end

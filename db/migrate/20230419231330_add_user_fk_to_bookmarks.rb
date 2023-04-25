class AddUserFkToBookmarks < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      Orangelight::Application.load_tasks
      Rake::Task['orangelight:clean:bookmarks:without_users'].execute
      # Add the constraint and validate it in two separate steps,
      # so that we avoid a lengthy lock on the bookmarks table
      add_foreign_key :bookmarks, :users, on_delete: :cascade, validate: false
      validate_foreign_key :bookmarks, :users
    end
  end

  def down
    ActiveRecord::Base.transaction do
      if foreign_key_exists? :bookmarks, :users
        remove_foreign_key :bookmarks, :users
      end
    end
  end
end

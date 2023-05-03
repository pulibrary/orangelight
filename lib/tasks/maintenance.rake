# frozen_string_literal: true

namespace :orangelight do
  namespace :clean do
    desc 'Delete guest users from User table'
    task guest_users: :environment do
      User.expire_guest_accounts
    end
    namespace :bookmarks do
      # TODO: remove the following task, since as of
      # migration 20230419231330, the database layer
      # will not allow bookmarks without a valid user
      task without_users: :environment do
        Bookmark.without_valid_user.destroy_all
      end
      # orangelight:clean:bookmarks:without_solr_documents
      task without_solr_documents: :environment do
        Bookmark.update_to_alma_ids
        Bookmark.destroy_without_solr_documents
      end
    end
  end

  namespace :migration do
    desc 'Downcase netids from CAS'
    task netids: :environment do
      DBMigrateUppercaseUsernames.run
    end
  end
end

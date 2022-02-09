# frozen_string_literal: true

namespace :orangelight do
  namespace :clean do
    desc 'Delete guest users from User table'
    task guest_users: :environment do
      User.expire_guest_accounts
    end
  end

  namespace :migration do
    desc 'Downcase netids from CAS'
    task netids: :environment do
      DBMigrateUppercaseUsernames.run
    end
  end
end

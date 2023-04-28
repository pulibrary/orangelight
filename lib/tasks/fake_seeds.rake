# frozen_string_literal: true
namespace :bookmarks do
  task seed_fakes: :environment do
    # Get some document_ids that are definitely in the index
    solr = Blacklight.default_index.connection
    response = solr.get 'select', params: { fl: 'id', rows: 800 }
    valid_ids = response["response"]["docs"].map { |doc| doc["id"] }
    invalid_ids = valid_ids.map(&:clone)
    # Make some fake document_ids that are definitely not in the index
    invalid_ids.map do |id|
      id[0..2] = "88"
      id
    end
    # Create fake bookmarks for existing users
    User.all.each.with_index do |user, index|
      Bookmark.create(user:, document_id: valid_ids[index])
      Bookmark.create(user:, document_id: invalid_ids[index])
    end
  end
end

namespace :users do
  task seed_fakes: :environment do
    50.times do |iteration|
      username = "username#{iteration}"
      email = "email-#{username}"
      foo = User.create(username:, email:, provider: 'cas',
                        password: 'foobarfoo', uid: username, guest: false)
      foo.save!
    end
    50.times do |iteration|
      username = "username#{iteration + 50}"
      email = "email-#{username}"
      foo = User.create(username:, email:, provider: 'cas',
                        password: 'foobarfoo', uid: username, guest: true)
      foo.save!
    end
  end
end

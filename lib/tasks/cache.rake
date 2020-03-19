# frozen_string_literal: true

namespace :cache do
  desc 'Clear the Rails cache'
  task clear: :environment do
    Rails.cache.clear
  end
end

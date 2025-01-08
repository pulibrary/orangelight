# frozen_string_literal: true

require "redis-client"

# nosemgrep
redis_config_from_yml = YAML.safe_load(ERB.new(Rails.root.join("config/redis.yml").read).result, aliases: true)[Rails.env].with_indifferent_access
redis_config = RedisClient.config(host: redis_config_from_yml[:host], port: redis_config_from_yml[:port], db: redis_config_from_yml[:db])

# Sidekiq::Client.reliable_push! unless Rails.env.test? # sidekiq pro feature, we would need the key and sidekiq pro gem to enable this
Sidekiq.configure_server do |config|
  config.redis = { url: redis_config.server_url }
  # config.super_fetch! # sidekiq pro feature
  # config.reliable_scheduler! # sidekiq pro feature
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_config.server_url }
end

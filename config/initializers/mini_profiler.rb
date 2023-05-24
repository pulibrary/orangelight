# frozen_string_literal: true

redis_config = YAML.safe_load(ERB.new(File.read(Rails.root.join("config", "redis.yml"))).result, aliases: true)[Rails.env].with_indifferent_access

Rack::MiniProfiler.config.storage_options = {
  host: redis_config[:host],
  port: redis_config[:port],
  db: redis_config[:db]
}
Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore

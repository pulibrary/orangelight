# frozen_string_literal: true

class Rack::Attack
  Rack::Attack.throttle('limit sitemap requests by IP', limit: 1, period: 10) do |request|
    request.ip if request.path == '/sitemap' && request.get?
  end
end

# frozen_string_literal: true

class Rack::Attack
  Rack::Attack.throttle('limit sitemap requests by IP', limit: 1, period: 10) do |request|
    { 'ip' => request.ip, 'path' => request.path } if /sitemap/.match(request.path) && request.get?
  end
end

class Rack::Attack
  Rack::Attack.throttle('limit sitemap requests by IP', limit: 1, period: 10) do |request|
    if request.path == '/sitemap' && request.get?
      request.ip
    end
  end
end

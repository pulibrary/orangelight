# frozen_string_literal: true

Datadog.configure do |c|
  c.tracer(enabled: false) unless Rails.env.production?
  # Rails
  c.use :rails

  # Net::HTTP
  c.use :http

  # Faraday
  c.use :faraday
end

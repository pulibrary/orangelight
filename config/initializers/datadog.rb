# frozen_string_literal: true

Datadog.configure do |c|
  c.tracing.enabled = false unless Rails.env.production?
  c.env = 'production'
  # Rails
  c.tracing.instrument :rails

  # Net::HTTP
  c.tracing.instrument :http

  # Faraday
  c.tracing.instrument :faraday
end

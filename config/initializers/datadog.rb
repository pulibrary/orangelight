# frozen_string_literal: true

if Rails.env.production?
  Datadog.configure do |c|
    c.tracing.enabled = false
    c.env = 'production'
    # Rails
    c.tracing.instrument :rails

    # Net::HTTP
    c.tracing.instrument :http

    # Faraday
    c.tracing.instrument :faraday
  end
end

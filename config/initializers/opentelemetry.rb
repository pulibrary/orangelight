# frozen_string_literal: true
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

unless Rails.env.local?
  OpenTelemetry::SDK.configure do |c|
    c.use 'OpenTelemetry::Instrumentation::Faraday'
    c.use 'OpenTelemetry::Instrumentation::Net::HTTP'
    c.use 'OpenTelemetry::Instrumentation::PG'
    c.use 'OpenTelemetry::Instrumentation::Rack'
    c.use 'OpenTelemetry::Instrumentation::Rails'
    c.use 'OpenTelemetry::Instrumentation::Rake'
    c.use 'OpenTelemetry::Instrumentation::Sidekiq'
  end
end

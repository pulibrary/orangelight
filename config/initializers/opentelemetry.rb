require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  # Set service information
  c.service_name = 'orangelight'
  c.service_version = ENV['APP_VERSION'] || 'unknown'

  # Configure resource attributes (equivalent to Datadog tags)
  c.resource = OpenTelemetry::SDK::Resources::Resource.create({
                                                                'service.name' => 'orangelight',
                                                                'service.version' => ENV['APP_VERSION'] || 'production',
                                                                'environment' => 'production',
                                                                'application' => 'orangelight',
                                                                'type' => 'webserver',
                                                                'host.name' => ENV['HOSTNAME'] || `hostname`.strip
                                                              })

  # Configure OTLP exporter
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: 'http://localhost:4317',
        headers: {},
        compression: 'gzip'
      )
    )
  )

  # Auto-instrument common libraries
  c.use_all # This includes Rails, Rack, ActiveRecord, Net::HTTP, etc.
end

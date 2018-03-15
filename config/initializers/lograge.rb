# frozen_string_literal: true

Rails.application.configure do
  # Lograge config
  config.lograge.enabled = true

  # We are asking here to log in RAW (which are actually ruby hashes).
  # The Ruby logging is going to take care of the JSON formatting.
  config.lograge.formatter = Lograge::Formatters::Logstash.new

  # This is is useful if you want to log query parameters
  config.lograge.custom_options = lambda do |_event|
    { ddsource: ['ruby'] }
  end
end

# frozen_string_literal: true
# Builds loggers for the libraries that log to stdout instead of going through
# the Rails logger: Sneakers and the OpenTelemetry SDK. The sneakers systemd
# unit redirects stdout into log/sneakers.log, so this is what decides the
# format of that file. Left to themselves the two libraries each use their own
# plain text format, which put two different shapes in that one file and gave
# our log collector nothing structured to index.
class StdoutLogger
  # Plain text with color is easier to follow when tailing a worker in a
  # terminal, so only emit JSON in the environments whose logs get shipped.
  def self.build(name)
    formatter = Rails.env.local? ? :color : :json
    SemanticLogger::Appender::IO.new($stdout, formatter:, level: :info).tap do |logger|
      logger.name = name
    end
  end
end

# frozen_string_literal: true
# Builds loggers for the libraries that log to stdout instead of going through
# the Rails logger: Sneakers and the OpenTelemetry SDK. The sneakers systemd
# unit redirects stdout into log/sneakers.log, so this is what decides the
# format of that file. Left to themselves the two libraries each use their own
# plain text format, which put two different shapes in that one file and gave
# our log collector nothing structured to index.
class StdoutLogger
  # JSON in every environment, so that what you read while tailing a worker is
  # the same shape the log collector indexes.
  def self.build(name)
    SemanticLogger::Appender::IO.new($stdout, formatter: :json, level: :info).tap do |logger|
      logger.name = name
    end
  end
end

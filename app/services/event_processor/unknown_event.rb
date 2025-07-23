# frozen_string_literal: true

class EventProcessor
  class UnknownEvent < Processor
    attr_reader :event
    def initialize(event)
      @event = event
    end

    # rubocop:disable Naming/PredicateMethod
    def process
      Rails.logger.info("Unable to process event type #{event_type}")
      false
    end
    # rubocop:enable Naming/PredicateMethod
  end
end

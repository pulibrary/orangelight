# frozen_string_literal: true

class EventProcessor
  attr_reader :event
  def initialize(event)
    @event = event
  end

  delegate :process, to: :processor

  private

    def event_type
      event['event']
    end

    def processor
      case event_type
      when 'CREATED'
        UpdateProcessor.new(event)
      when 'UPDATED'
        UpdateProcessor.new(event)
      when 'DELETED'
        DeleteProcessor.new(event)
      else
        UnknownEvent.new(event)
      end
    end
end

# frozen_string_literal: true

class EventHandler
  include Sneakers::Worker
  from_queue :orangelight

  def work(msg)
    msg = JSON.parse(msg)
    result = EventProcessor.new(msg).process
    if result
      ack!
    else
      reject!
    end
  end
end

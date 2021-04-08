# frozen_string_literal: true

class EventHandler
  include Sneakers::Worker
  if Rails.configuration.use_alma
    from_queue :catalog_alma_qa
  else
    from_queue :orangelight
  end

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

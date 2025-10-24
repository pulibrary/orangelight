module Requests
  class AsyncPatronRequest
    def initialize(user:)
      @thread = Thread.new { Patron.authorize(user:) }
    end

    def patron
      @patron ||= thread.value
    end

      private

        attr_reader :thread
  end
end

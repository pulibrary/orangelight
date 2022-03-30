module Requests
  class Service
    def initialize(params)
      @type = params[:type]
    end

    def handle
      raise Exception, "#{self.class}: handle() must be implemented by Service concrete sub-class, for standard services!"
    end

    def submitted
      # this should return an array of items successfully submitted to the service on a request
      raise Exception, "#{self.class}: submitted() is not implemented"
    end

    def errors
      # this should return an array of errors returned by the service on a request
      raise Exception, "#{self.class}: errors() is not implemented"
    end

    attr_reader :type
  end
end

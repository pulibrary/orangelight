module Requests
  class EmptyRequestDecorator
    attr_reader :system_id, :format_brief_record_display, :non_requestable_mesage

    def initialize(system_id:)
      @system_id = system_id
      @requestable_list = []
      @format_brief_record_display = ""
      @non_requestable_mesage = "Please choose a specific location on the Record Page!"
    end

    def requestable
      @requestable_list
    end

    def requestable?
      false
    end

    def catalog_url
      "/catalog/#{system_id}"
    end
  end
end

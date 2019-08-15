# frozen_string_literal: true

module Orangelight
  module Stackmap
    extend ActiveSupport::Concern

    def stackmap
      @response, @document = search_service.fetch params[:id]
      stackmap_service = ::StackmapService::Url.new(document: @document,
                                                    loc: params[:loc], cn: params[:cn])
      @url = stackmap_service.url
      @call_number = stackmap_service.preferred_callno
      @location_label = stackmap_service.location_label
      render layout: false if request.xhr?
    end
  end
end

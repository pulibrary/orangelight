# frozen_string_literal: true

module Orangelight
  module Stackmap
    extend ActiveSupport::Concern

    def stackmap
      @response, @document = fetch params[:id]
      redirect_to ::StackmapService::Url.new(document: @document, loc: params[:loc]).url
    end
  end
end

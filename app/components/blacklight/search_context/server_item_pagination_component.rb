# frozen_string_literal: true

# This can be removed after migrating to Blacklight 8
module Blacklight
  module SearchContext
    # This class makes the ServerItemPaginationComponent that is present in Blacklight 8
    # available while we are still on Blacklight 7
    class ServerItemPaginationComponent < Blacklight::SearchContextComponent
      with_collection_parameter :search_context

      def initialize(search_context:, search_session:, current_document:)
        @search_context = search_context
        @search_session = search_session
        @current_document_id = current_document.id
      end
    end
  end
end

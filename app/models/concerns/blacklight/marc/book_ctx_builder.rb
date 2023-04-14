# frozen_string_literal: true
require 'openurl/context_object'

module Blacklight
  module Marc
    # Create an OpenUrl ContextObject for a book
    class BookCtxBuilder < CtxBuilder
      def build
        ctx.referent.set_format('book')
        apply_metadata
        ctx
      end

      private

        def mapping
          {
            genre: 'book',
            au: author,
            aucorp: publisher,
            pub: publisher,
            edition:,
            isbn:,
            date:
          }
        end

        def edition
          @document['edition_display']&.first
        end
    end
  end
end

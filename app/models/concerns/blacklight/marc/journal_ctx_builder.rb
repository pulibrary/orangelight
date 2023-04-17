# frozen_string_literal: true
require 'openurl/context_object'

module Blacklight
  module Marc
    # Create an OpenUrl ContextObject for a journal
    class JournalCtxBuilder < CtxBuilder
      def build
        ctx.referent.set_format('journal')
        apply_metadata
        ctx
      end

      private

        def mapping
          {
            genre: 'serial',
            aucorp: author,
            issn:
          }
        end
    end
  end
end

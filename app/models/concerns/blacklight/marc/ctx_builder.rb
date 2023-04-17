# frozen_string_literal: true
require 'openurl/context_object'

module Blacklight
  module Marc
    # Create a generic OpenUrl ContextObject
    class CtxBuilder
      def initialize(document:, format:)
        @document = document
        @format = format
      end

      def build
        ctx.referent.set_format(genre)
        apply_metadata
        ctx
      end

      def ctx
        @ctx ||= OpenURL::ContextObject.new
      end

      private

        def apply_metadata
          mapping.each do |key, value|
            ctx.referent.set_metadata(key.to_s, value)
          end
          add_identifiers
        end

        def add_identifiers
          id = @document['id']
          ctx.referent.add_identifier("https://bibdata.princeton.edu/bibliographic/#{id}")
          ctx.referrer.add_identifier('info:sid/catalog.princeton.edu:generator')
          ctx.referent.add_identifier("info:oclcnum/#{@document['oclc_s'].first}") unless @document['oclc_s'].nil?
          ctx.referent.add_identifier("info:lccn/#{@document['lccn_s'].first}") unless @document['lccn_s'].nil?
        end

        def mapping
          {
            genre:,
            creator: author,
            aucorp: publisher,
            pub: publisher,
            format: @format,
            issn:,
            isbn:,
            date:
          }
        end

        def author
          @document['author_citation_display']&.first
        end

        def date
          @document['pub_date_display']&.first
        end

        def genre
          @format == 'conference' ? @format : 'unknown'
        end

        def isbn
          @document['isbn_s']&.first
        end

        def issn
          @document['issn_s']&.first
        end

        def publisher
          @document['pub_citation_display']&.first
        end
    end
  end
end

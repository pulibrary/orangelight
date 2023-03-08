# frozen_string_literal: true
require 'openurl'

module Requests
  class SolrOpenUrlContext
    attr_reader :ctx
    attr_reader :solr_doc

    TYPE_MAPPING = {
      book: { btitle: :title, au: :author, pub: :publisher_info, edition: :edition, isbn: :isbn },
      journal: { atitle: :title, aucorp: :author, issn: :issn },
      unknown: { creator: :author, aucorp: :publisher_info, pub: :publisher_info, format: :format, issn: :issn, isbn: :isbn }
    }.freeze
    private_constant :TYPE_MAPPING

    include OpenURL

    def initialize(solr_doc:)
      @solr_doc = solr_doc
      @ctx = build_ctx
    end

    def openurl_ctx_kev
      ctx.kev
    end

    ## double check what are valid openURL formsts in the catatlog
    ## look at our choices and map
    # def format_to_openurl_genre(format)
    #   return 'book' if format == 'book'
    #   return 'journal' if format == 'serial'
    #   return 'journal' if format == 'journal'
    #   'unknown'
    # end

    private

      def build_ctx
        metadata = build_metadata(solr_doc:)
        ctx = if metadata[:format] == 'book'
                copy_metadata(format: :book, metadata:)
              elsif /journal/i.match?(metadata[:format]) # checking using include because institutions may use formats like Journal or Journal/Magazine
                copy_metadata(format: :journal, metadata:)
              else
                copy_metadata(format: :unknown, metadata:)
              end
        ctx
      end

      # rubocop:disable Metrics/AbcSize
      def build_metadata(solr_doc:)
        metadata = {}
        metadata[:id] = solr_doc['id']
        metadata[:title] = set_title unless solr_doc['title_citation_display'].nil?
        metadata[:date] = solr_doc['pub_date_display'].first unless solr_doc['pub_date_display'].nil?
        metadata[:author] = solr_doc['author_citation_display'].first unless solr_doc['author_citation_display'].nil?
        metadata[:publisher_info] = solr_doc['pub_citation_display'].first unless solr_doc['pub_citation_display'].nil?
        metadata[:edition] = solr_doc['edition_display'].first unless solr_doc['edition_display'].nil?
        metadata[:format] = Array.new(solr_doc['format']).first.downcase.strip if solr_doc['format'].present?
        metadata[:format] ||= 'unknown'
        metadata[:isbn] = solr_doc['isbn_s'].first unless solr_doc['isbn_s'].nil?
        metadata[:issn] = solr_doc['issn_s'].first unless solr_doc['issn_s'].nil?
        metadata[:oclc] = solr_doc['oclc_s'].first unless solr_doc['oclc_s'].nil?
        metadata[:lccn] = solr_doc['lccn_s'].first unless solr_doc['lccn_s'].nil?
        metadata
      end
      # rubocop:enable Metrics/AbcSize

      def copy_metadata(format:, metadata:)
        ctx = ContextObject.new
        ctx.referent.set_format(format.to_s)
        copy_generic_metadata(ctx:, metadata:, format:)
        # canonical identifier for the citation?
        ctx.referent.add_identifier("https://bibdata.princeton.edu/bibliographic/#{metadata[:id]}")
        copy_referrer_info(ctx:, metadata:)
        TYPE_MAPPING[format].each { |identifier, metadata_key| ctx.referent.set_metadata(identifier.to_s, metadata[metadata_key]) }
        ctx
      end

      def copy_referrer_info(ctx:, metadata:)
        ctx.referrer.add_identifier('info:sid/catalog.princeton.edu:generator')
        ctx.referent.add_identifier("info:oclcnum/#{metadata[:oclc]}") unless metadata[:oclc].nil?
        ctx.referent.add_identifier("info:lccn/#{metadata[:lccn]}") unless metadata[:lccn].nil?
      end

      def copy_generic_metadata(ctx:, metadata:, format:)
        ctx.referent.set_metadata('genre', format.to_s)
        ctx.referent.set_metadata('title', metadata[:title])
        ctx.referent.set_metadata('date', metadata[:date])
      end

      def set_title
        solr_doc['title_citation_display'].first.truncate(247)
      end
  end
end

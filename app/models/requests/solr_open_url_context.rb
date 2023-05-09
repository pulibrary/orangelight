# frozen_string_literal: true

module Requests
  class SolrOpenUrlContext
    attr_reader :ctx

    def initialize(solr_doc:)
      return if solr_doc._source.empty?

      @ctx = solr_doc.to_ctx
      # Dates are not desired for other OpenURLs, but are
      # essential for ILLiad requests
      @ctx.referent.set_metadata('date', solr_doc['pub_date_display'].first) if @ctx.referent.format == 'journal' && solr_doc['pub_date_display'].present?
    end

    def openurl_ctx_kev
      ctx.kev
    end
  end
end

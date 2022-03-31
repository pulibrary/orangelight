# frozen_string_literal: true
require 'borrow_direct'

module Requests
  module BdUtils
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    # @params Hash in the form of
    # { symbol: 'value' }
    # example
    # {
    #    title: 'The White Whale',
    #    author: 'Ahab'
    # }
    def fallback_query
      ::BorrowDirect::GenerateQuery.new.normalized_author_title_query(fallback_query_params)
    end

    # returns the keys in a solr document that are relevant
    # for a Borrow Direct fall query
    def fallback_query_params
      params = {}
      fallback_keys.each do |key, value|
        params[value] = doc[key].first unless doc[key].nil?
      end
      params[:max_title_words] = 10
      params
    end

    private

      # assume all keys are multi-valued
      def fallback_keys
        {
          'title_citation_display' => :title,
          'author_citation_display' => :author
        }
      end
  end
end

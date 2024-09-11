# frozen_string_literal: true

module Orangelight
  module Document
    # Special alma functionality for SolrDocument
    module Scsb
      def scsb_record?
        /^SCSB-\d+/.match?(self['id'])
      end
    end
  end
end

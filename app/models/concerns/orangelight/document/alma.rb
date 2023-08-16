# frozen_string_literal: true

module Orangelight
  module Document
    # Special alma functionality for SolrDocument
    module Alma
      def alma_record?
        /^[0-9]+/.match?(self['id'])
      end
    end
  end
end

# frozen_string_literal: true

module Orangelight
  module Document
    # Special alma functionality for SolrDocument
    module Dspace
      def dspace_record?
        /^dsp[\da-z]{11}/.match?(self['id'])
      end
    end
  end
end

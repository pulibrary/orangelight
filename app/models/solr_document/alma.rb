# frozen_string_literal: true

class SolrDocument
  # Special alma functionality for SolrDocument
  module Alma
    def alma_record?
      /^[0-9]+/.match?(self['id'])
    end
  end
end

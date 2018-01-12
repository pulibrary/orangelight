class SolrDocument
  class Identifier
    attr_reader :identifier_type, :value
    def initialize(identifier_type, value)
      @identifier_type = identifier_type
      @value = value
    end

    def to_html
      helper.tag :meta, property: property, itemprop: itemprop, content: value
    end

    # @return [String] RDF property either absolute or relative to
    #   http://id.loc.gov/vocabulary/identifiers/
    def property
      property_mapping[identifier_type]
    end

    # @return [String] Schema.org item property.
    def itemprop
      itemprop_mapping[identifier_type]
    end

    def data_key
      identifier_type.gsub('_s', '')
    end

    private

      def property_mapping
        {
          'isbn_s' => 'isbn',
          'lccn_s' => 'lccn',
          'oclc_s' => 'http://purl.org/library/oclcnum'
        }
      end

      def itemprop_mapping
        {
          'isbn_s' => 'isbn'
        }
      end

      def helper
        @helper ||= ActionController::Base.helpers
      end
  end
end

# frozen_string_literal: true
class SolrDocument
  # Standard Numbers functionality for SolrDocument
  module StandardNumbers
    def standard_numbers?
      standard_number_fields.any? { |field| key? field }
    end

    private

      def standard_number_fields
        %w[lccn_s isbn_s issn_s oclc_s]
      end
  end
end

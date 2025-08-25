# frozen_string_literal: true
# This component is responsible for rendering a div that will be replaced by a Libmap Button
# a holding on the search results page
class Holdings::LibmapButtonComponent < ViewComponent::Base
  def initialize(adapter, holding_hash)
    @adapter = adapter
    @holding_hash = holding_hash
  end

    private

      attr_reader :adapter, :holding_hash

      def title
        adapter.document['title_display']
      end

      def location
        holding_hash['library']
      end

      def collection
        holding_hash['location'].to_s
      end

      def call_number
        holding_hash['call_number']
      end
end

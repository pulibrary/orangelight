module Requests
  class Mapable
    attr_reader :bib_id, :holdings, :location_code

    def initialize(bib_id:, holdings:, location_code:)
      @bib_id = bib_id
      @holdings = holdings
      @location_code = location_code
    end

    def map_url(mfhd_id)
      "#{Requests::Config[:pulsearch_base]}/catalog/#{bib_id}/stackmap?#{map_params(mfhd_id).to_query}"
    end

    private

      def map_params(mfhd_id)
        {
          cn: holdings[mfhd_id]['call_number'],
          loc: location_code
        }
      end
  end
end

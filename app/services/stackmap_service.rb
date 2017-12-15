class StackmapService
  # A url to the stackmap for the bib record
  class Url
    # Constructor
    # @param document [SolrDocument] Solr document for bib record
    # @param loc [String] Bib record location code
    # @param cn [String] optional provided call number
    def initialize(document:, loc:, cn: nil)
      @document = document
      @loc = loc
      @cn = cn
    end

    # Return the correct stackmap url ased on the location information of the bib record
    # @return [String] stackmap url
    def url
      if valid?
        if missing_stackmap_reserves.include? @loc
          missing_stackmap_reserves[@loc]
        elsif stackmap_libs.include? lib
          stackmap_url
        else
          locator_url
        end
      else
        fallback_url
      end
    end

    private

      def locator_url
        "https://library.princeton.edu/locator/index.php?loc=#{@loc}&id=#{bibid}"
      end

      def stackmap_url
        stackmap_url = 'https://princeton.stackmap.com/view/'
        stackmap_params = {
          callno: callno,
          location: @loc,
          library: holding_location[:library][:label]
        }
        "#{stackmap_url}?#{stackmap_params.to_query}"
      end

      # redirects to catalog record page if location or call number is missing_stackmap_reserves
      # takes user to catalog home page if @document (bibid) is missing
      def fallback_url
        "/catalog/#{@document.to_param}"
      end

      def bibid
        @bibid ||= @document[:id]
      end

      # use the optionally provided call number
      def callno
        @cn ||= preferred_callno
      end

      def preferred_callno
        if by_title_locations.include? @loc
          @document['title_display']
        else
          @document['call_number_browse_s'].first
        end
      end

      # Need to include all non-stackmap libraries here to support the Main Catalog
      # that displays the locator link on EVERY record.
      def locator_libs
        %w[firestone hrc annexa annexb mudd online rare recap]
      end

      def stackmap_libs
        %w[architecture eastasian engineering lewis mendel marquand plasma stokes]
      end

      def missing_stackmap_reserves
        {
          'ueso' => 'https://library.princeton.edu/architecture',
          'piaprr' => 'https://library.princeton.edu/stokes',
          'pplr' => 'https://library.princeton.edu/plasma-physics',
          'scigr' => 'https://library.princeton.edu/lewis'
        }
      end

      def by_title_locations
        %w[sciss pplps sprps spiaps]
      end

      def holding_location
        @holding_location ||= Orangelight.locations[@loc]
      end

      def lib
        @lib ||= holding_location[:library][:code]
      end

      def valid?
        !holding_location.nil? && !@document.nil?
      end
  end
end

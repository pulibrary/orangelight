# frozen_string_literal: true

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
        if StackmapService::Url.missing_stackmap_reserves.include? @loc
          StackmapService::Url.missing_stackmap_reserves[@loc]
        elsif stackmap_libs.include? lib
          stackmap_url
        else
          locator_url
        end
      else
        fallback_url
      end
    end

    def preferred_callno
      if by_title_locations.include? @loc
        @document['title_display']
      else
        @cn || @document['call_number_browse_s']&.first
      end
    end

    def location_label
      return nil if holding_location.nil?
      holding_location[:label].presence || holding_location[:library][:label]
    end

    def self.missing_stackmap_reserves
      {
        'arch$res3hr' => 'https://library.princeton.edu/architecture',
        'stokes$respiapr' => 'https://library.princeton.edu/stokes',
        'plasma$res' => 'https://library.princeton.edu/plasma-physics',
        'lewis$gr' => 'https://library.princeton.edu/lewis'
      }
    end

    private

      def locator_url
        base_url = Orangelight.config['firestone_locator_base_url'] || 'https://locator-prod.princeton.edu'
        "#{base_url}/index.php?loc=#{@loc}&id=#{bibid}&embed=true"
      end

      def stackmap_url
        stackmap_url = 'https://princeton.stackmap.com/view/'
        stackmap_params = {
          callno:,
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

      # use the optionally provided call number unless if by title location
      def callno
        @cn = preferred_callno
      end

      def stackmap_libs
        if Flipflop.firestone_locator?
          %w[arch eastasian engineer lewis mendel plasma stokes]
        else
          %w[arch eastasian engineer lewis mendel plasma stokes firestone]
        end
      end

      def by_title_locations
        %w[lewis$serial plasma$ps stokes$sprps stokes$spiaps]
      end

      def holding_location
        @holding_location ||= Bibdata.holding_locations[@loc]
      end

      def lib
        @lib ||= holding_location[:library][:code]
      end

      def valid?
        !holding_location.nil? && !@document.nil?
      end
  end
end

module Orangelight
  module Stackmap
    extend ActiveSupport::Concern

    def stackmap
      @response, @document = fetch params[:id]
      redirect_to url
    end

    private

      def url
        if locator_libs.include? lib
          locator_url
        elsif stackmap_libs.include? lib
          stackmap_url
        else
          "https://pulsearch.princeton.edu/requests/#{params[:id]}"
        end
      end

      def locator_url
        "https://library.princeton.edu/locator/index.php?loc=#{params[:loc]}&id=#{params[:id]}"
      end

      def stackmap_url
        stackmap_url = 'https://princeton.stackmap.com/view/'
        stackmap_params = {
          callno: callno,
          location: params[:loc],
          library: holding_location[:library][:label]
        }
        "#{stackmap_url}?#{stackmap_params.to_query}"
      end

      def callno
        if by_title_locations.include? params[:loc]
          @document['title_sort'].first
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

      def closed_stack_reserves
        %w[ueso spir piaprr gstr strp strr pplr scires scigr scilal sar musg musr]
      end

      def by_title_locations
        %w[sciss pplps sprps spiaps]
      end

      def holding_location
        @holding_location ||= Orangelight.locations[params[:loc]]
      end

      def lib
        @lib ||= holding_location[:library][:code]
      end

      # def hours_location
      #   @hours_location ||= fetch_hours_location
      # end

      def valid?
        !holding_location.nil? && (cn || !@document.empty?)
      end

      def on_reserve?
        closed_stack_reserves.include? params[:loc]
      end
  end
end

# frozen_string_literal: true
module Requests
  module Aeon
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    def aeon_mapped_params
      params = {
        Action: '10',
        Form: '21',
        ItemTitle: aeon_title.truncate(247),
        ItemAuthor: author,
        ItemDate: pub_date,
        ItemVolume: item_volume
      }
      params[:ItemNumber] = item[:barcode] if barcode?
      params.merge! aeon_basic_params
      params.reject { |_k, v| v.nil? }
    end

    ## params shared by both alma and non-alma aeon requests
    def aeon_basic_params
      {
        ReferenceNumber: bib[:id],
        CallNumber: call_number,
        Site: site,
        Location: shelf_location_code,
        SubLocation: sub_location,
        ItemInfo1: I18n.t("requests.aeon.access_statement")
      }.compact
    end

    def aeon_request_url
      AeonUrl.new(document: bib, holding: holding.to_h, item:).to_s
    end

    def site
      if location[:holding_library].present?
        holding_location_to_site(location['holding_library']['code'])
      elsif location['library']['code'] == 'eastasian' && aeon_location?
        'EAL'
      elsif location['library']['code'] == 'marquand'  && aeon_location?
        'MARQ'
      elsif location['library']['code'] == 'mudd'
        'MUDD'
      else
        "RBSC"
      end
    end

    private

      def holding_location_to_site(location_code)
        if  location_code == 'eastasian' && aeon_location?
          'EAL'
        elsif location_code == 'marquand' && aeon_location?
          'MARQ'
        elsif location_code == 'mudd' && aeon_location?
          'MUDD'
        else
          'RBSC'
        end
      end

      def aeon_location?
        location['aeon_location'] == true
      end

      def call_number
        holding.holding_data['call_number']
      end

      def pub_date
        bib[:pub_date_start_sort]
      end

      def shelf_location_code
        holding.holding_data['location_code']
      end

      def item_volume
        item.description if item.present? && enumerated?
      end

      def sub_location
        holding.holding_data['sub_location']&.first
      end

      def aeon_title
        "#{bib[:title_display]}#{genre}"
      end

      ## Don T requested this be appended when present
      def genre
        " [ #{bib[:form_genre_display].first} ]" unless bib[:form_genre_display].nil?
      end

      def author
        bib[:author_display]&.join(" AND ")
      end
  end
end

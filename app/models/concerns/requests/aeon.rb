# frozen_string_literal: true
module Requests
  module Aeon
    # for Aeon Related Bibliographic Helpers
    extend ActiveSupport::Concern

    # for use with only non-alma thesis records
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
      params[:genre] = 'thesis' if thesis?
      params[:genre] = 'numismatics' if numismatics?
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
      AeonUrl.new(document: bib, holding:, item:).to_s
    end

    # returns encoded OpenURL string for alma derived records
    def aeon_openurl(ctx)
      if item.present?
        ctx.referent.set_metadata('iteminfo5', item[:id]&.to_s)
        if enumerated?
          ctx.referent.set_metadata('volume', item.enum_value)
          ctx.referent.set_metadata('issue', item[:chron_display]) if item[:chron_display].present?
        else
          ctx.referent.set_metadata('volume', holding.first.last['location_has']&.first)
          ctx.referent.set_metadata('issue', nil)
        end
      end
      aeon_params = aeon_basic_params
      aeon_params[:ItemNumber] = barcode if barcode?
      ## returned mashed together in an encoded string
      "#{ctx.kev}&#{aeon_params.to_query}"
    end

    def site
      if holding.key? 'thesis'
        'MUDD'
      elsif location[:holding_library].present?
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
        holding.first.last['call_number']
      end

      def pub_date
        bib[:pub_date_start_sort]
      end

      def shelf_location_code
        holding.first.last['location_code']
      end

      def item_volume
        item["enumeration"] if item.present? && enumerated?
      end

      def sub_location
        holding.first.last['sub_location']&.first
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

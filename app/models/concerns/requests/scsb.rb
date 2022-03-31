# frozen_string_literal: true
module Requests
  module Scsb
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def items_by_id(id, source = 'scsb')
      response = scsb_conn.post do |req|
        req.url '/sharedCollection/bibAvailabilityStatus'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['api_key'] = scsb_auth_key
        req.body = scsb_bib_id_request(id, source).to_json
      end
      parse_scsb_response(response)
    end

    # Prefer lookup by bib over barcode
    # def items_by_barcode(barcodes)
    #   response = scsb_conn.post do |req|
    #     req.url '/sharedCollection/itemAvailabilityStatus'
    #     req.headers['Content-Type'] = 'application/json'
    #     req.headers['Accept'] = 'application/json'
    #     req.headers['api_key'] = scsb_auth_key
    #     req.body = scsb_barcode_request(barcodes).to_json
    #   end
    #   parse_scsb_response(response)
    # end

    def scsb_request(request_params)
      response = scsb_conn.post do |req|
        req.url '/requestItem/requestItem'
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.headers['api_key'] = scsb_auth_key
        req.body = request_params.to_json
      end
      response
    end

    # not being used
    # def scsb_item_information(request_params)
    #   response = scsb_conn.post do |req|
    #     req.url '/requestItem/validateItemRequestInformation'
    #     req.headers['Content-Type'] = 'application/json'
    #     req.headers['Accept'] = 'application/json'
    #     req.headers['api_key'] = scsb_auth_key
    #     req.body = request_params.to_json
    #   end
    #   parse_scsb_response(response)
    # end

    def parse_scsb_response(response)
      parsed = response.status == 200 ? JSON.parse(response.body) : {}
      parsed.class == Hash ? parsed.with_indifferent_access : parsed
    rescue StandardError => error
      Rails.logger.error("Invalid response from the SCSB server: #{error}")
      { success: false, screenMessage: 'A server error arose, please contact your local administrator for assistance.' }
    end

    # Not being used at the moment
    # def scsb_barcode_request(barcodes)
    #   {
    #     barcodes: barcodes
    #   }
    # end

    def scsb_bib_id_request(id, source)
      {
        bibliographicId: id,
        institutionId: source
      }
    end

    def scsb_conn
      conn = Faraday.new(url: Requests::Config[:scsb_base]) do |faraday|
        faraday.request  :url_encoded # form-encode POST params
        faraday.response :logger unless Rails.env.test? # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
      end
      conn
    end

    def scsb_param_mapping(bib, user, item)
      request_type = if item["delivery_mode_#{item['item_id']}"].nil?
                       item['type']
                     else
                       item["delivery_mode_#{item['item_id']}"]
                     end
      { author: item[:edd_author], bibId: bib[:id],
        callNumber: item[:call_number], chapterTitle: item[:edd_art_title],
        deliveryLocation: item[:pick_up] || "", emailAddress: user.active_email,
        endPage: item[:edd_end_page], issue: item[:edd_issue], itemBarcodes: [item[:barcode]],
        itemOwningInstitution: scsb_owning_institution(item[:location_code]),
        patronBarcode: user.barcode || '198572131', requestNotes: item[:edd_note],
        requestType: scsb_request_map(request_type), requestingInstitution: requesting_institution,
        startPage: item[:edd_start_page], titleIdentifier: bib[:title],
        username: user.netid, volume: item[:edd_volume_number] }
    end

    # not being used
    # def scsb_topic_type(scsb_request_type)
    #   if scsb_request_type == 'EDD'
    #     '/topic/PUL.EDDT'
    #   elsif scsb_request_type == 'RECALL'
    #     '/topic/PUL.RecallT'
    #   else
    #     '/topic/PUL.RequestT'
    #   end
    # end

    def scsb_request_map(request_type)
      if request_type == 'edd'
        'EDD'
      else
        'RETRIEVAL' # Default is print retrieval
      end
    end

    def requesting_institution
      'PUL'
    end

    def scsb_owning_institution(location)
      Requests::Config[:recap_partner_locations].fetch(location, "PUL")
    end

    private

      def scsb_auth_key
        if !Rails.env.test?
          ENV['SCSB_AUTH_KEY']
        else
          'TESTME'
        end
      end
  end
end

# frozen_string_literal: true
module Requests
  module Bibdata
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def solr_doc(system_id)
      response = Faraday.get "#{Requests.config[:pulsearch_base]}/catalog/#{system_id}/raw"
      parse_response(response)
    end

    def items_by_bib(system_id)
      response = bibdata_conn.get "/availability?id=#{system_id}"
      parse_response(response)
    end

    def items_by_mfhd(system_id, mfhd_id)
      response = bibdata_conn.get "/bibliographic/#{system_id}/holdings/#{mfhd_id}/availability.json"
      parse_response(response)
      # [{"barcode" => "32101098997032", "id" => "23664271880006421", "holding_id" => "22664271890006421", "copy_number" => "0", "status" => "Available", "status_label" => "Item in place", "status_source" => "base_status", "process_type" => nil, "on_reserve" => "N", "item_type" => "Gen", "pickup_location_id" => "firestone", "pickup_location_code" => "firestone", "location" => "firestone$stacks", "label" => "Firestone Library - Stacks", "description" => "", "enum_display" => "", "chron_display" => "", "requested" => false, "in_temp_library" => false}]
    end

    def get_location_data(location_code)
      response = bibdata_conn.get "/locations/holding_locations/#{location_code}.json"
      parse_response(response)
    end

    def bibdata_conn
      conn = Faraday.new(url: Requests.config[:bibdata_base]) do |faraday|
        faraday.request  :url_encoded # form-encode POST params
        # faraday.response :logger                  # log requests to STDOUT
        faraday.response :logger unless Rails.env.test?
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
      end
      conn
    end

    def parse_response(response)
      parsed = response.status == 200 ? parse_json(response.body) : {}
      parsed.class == Hash ? parsed.with_indifferent_access : parsed
    end

    def parse_json(data)
      JSON.parse(data)
    end

    # :reek:TooManyStatements
    # :reek:UtilityFunction
    def build_pick_ups
      pick_up_locations = []
      request_delivery_locations = Requests::BibdataService.delivery_locations
      request_delivery_locations.each_value do |pick_up|
        pick_up_locations << { label: pick_up["label"], gfa_pickup: pick_up["gfa_pickup"], pick_up_location_code: pick_up["library"]["code"] || 'firestone', staff_only: pick_up["staff_only"] } if pick_up["pickup_location"] == true
      end
      # Filter pickup locations based on this location's code:
      # - When code is 'firestone$pf', only include PF locations
      # - All other locations, exclude PF locations
      filtered_locations = Requests::Location.filter_pick_up_locations_by_code(pick_up_locations, location_code)
      Requests::Location.sort_pick_up_locations(filtered_locations)
    end

    # get the location contact email from thr delivery locations via the library code
    def get_location_contact_email(location_code)
      code = get_location_data(location_code)
      library_code = code[:library]["code"]
      return I18n.t('requests.on_shelf.email') if library_code == "firestone"
      delivery_location = Requests::BibdataService.delivery_locations.select { |_key, value| value[:library][:code] == library_code }
      delivery_location.values.first[:contact_email]
    end
  end
end

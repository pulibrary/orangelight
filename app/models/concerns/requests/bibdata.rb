# frozen_string_literal: true
module Requests
  module Bibdata
    # for PUL Bibliographic Helpers
    extend ActiveSupport::Concern

    def solr_doc(system_id)
      response = Faraday.get "#{Requests::Config[:pulsearch_base]}/catalog/#{system_id}/raw"
      parse_response(response)
    end

    def items_by_bib(system_id)
      response = bibdata_conn.get "/availability?id=#{system_id}"
      parse_response(response)
    end

    def items_by_mfhd(system_id, mfhd_id)
      # response = bibdata_conn.get "/availability?mfhd=#{mfhd_id}"
      response = bibdata_conn.get "/bibliographic/#{system_id}/holdings/#{mfhd_id}/availability.json"
      parse_response(response)
    end

    def get_location_data(location_code)
      response = bibdata_conn.get "/locations/holding_locations/#{location_code}.json"
      parse_response(response)
    end

    def bibdata_conn
      conn = Faraday.new(url: Requests::Config[:bibdata_base]) do |faraday|
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

    ## Accepts an array of location hashes and sorts them according to our quirks
    def sort_pick_ups(locs)
      # staff only locations go at the bottom of the list and Firestone to the top

      public_locs = locs.select { |loc| loc[:staff_only] == false }
      public_locs.sort_by! { |loc| loc[:label] }

      firestone = public_locs.find { |loc| loc[:label] == "Firestone Library" }
      public_locs.insert(0, public_locs.delete_at(public_locs.index(firestone))) unless firestone.nil?

      staff_locs = locs.select { |loc| loc[:staff_only] == true }
      staff_locs.sort_by! { |loc| loc[:label] }

      staff_locs.each do |loc|
        loc[:label] = loc[:label] + " (Staff Only)"
      end
      public_locs + staff_locs
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

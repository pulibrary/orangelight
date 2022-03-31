# frozen_string_literal: true
module Requests
  class BibdataService
    def self.connection
      Faraday.new(url: Requests::Config[:bibdata_base]) do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.response :logger unless Rails.env.test?
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def self.delivery_locations
      # check cache; return unless nil
      locations = Rails.cache.fetch('delivery_locations', expires_in: 24.hours)
      return locations unless locations.nil?

      # don't cache if we didn't get a success
      locations = {}.with_indifferent_access

      response = connection.get "/locations/delivery_locations.json"
      return locations unless response.status == 200

      JSON.parse(response.body).each do |location|
        locations[location['gfa_pickup']] = location.with_indifferent_access
      end

      Rails.cache.write('delivery_locations', locations, expires_in: 24.hours)
      locations
    end
  end
end

# frozen_string_literal: true
module Requests
  class BibdataService
    def self.connection
      Faraday.new(url: Requests.config[:bibdata_base]) do |faraday|
        faraday.request :url_encoded # form-encode POST params
        faraday.response :logger unless Rails.env.test?
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def self.delivery_locations
      locations = Rails.cache.read('delivery_locations')
      return locations unless locations.nil?

      response = connection.get("/locations/delivery_locations.json")
      return [] unless response.status == 200

      locations = JSON.parse(response.body).map(&:with_indifferent_access)
      Rails.cache.write('delivery_locations', locations, expires_in: 24.hours)
      locations
    end
  end
end

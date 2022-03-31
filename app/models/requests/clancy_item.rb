# frozen_string_literal: true
require 'faraday'

module Requests
  class ClancyItem
    attr_reader :clancy_conn, :api_key, :barcode, :errors

    def initialize(barcode: nil, connection: Faraday.new(url: Requests::Config[:clancy_base]))
      @clancy_conn = connection
      @api_key = Requests::Config[:clancy_api_key]
      @barcode = barcode
      @errors = []
    end

    def status
      @status ||= load_clancy_status
    end

    def not_at_clancy?
      return true unless status["success"]
      "Item not Found" == status["status"]
    end

    def at_clancy?
      !not_at_clancy?
    end

    def available?
      return false unless status["success"]
      ["Item In at Rest"].include?(status["status"]) # assuming there may be more than one available statuses
    end

    def request(hold_id:, patron:, location: 'MQ')
      response = request_item(hold_id: hold_id, patron: patron, location: location)
      return false unless response["success"]

      request_response = response["results"].first
      if request_response["deny"] == "N"
        true
      else
        errors << request_response["istatus"]
        false
      end
    end

    private

      def load_clancy_status
        return empty_status if barcode.blank?

        response = get_clancy(url: "itemstatus/v1/#{barcode}")
        if response.success?
          JSON.parse(response.body)
        else
          errors << "Error connecting with Clancy: #{response.status}"
          empty_status
        end
      end

      def get_clancy(url:)
        clancy_conn.get do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['X-API-Key'] = api_key
        end
      end

      def post_clancy(url:, body:)
        clancy_conn.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['X-API-Key'] = api_key
          req.body = body
        end
      end

      def empty_status
        { "success" => false }
      end

      def request_item(location:, hold_id:, patron:, request_type: "PYR")
        body = { "requests": [{ "request_id": hold_id, "request_type": request_type, "barcode": barcode, "stop": location, "requestor": "#{patron.first_name} #{patron.last_name}", "patron_id": patron.university_id }] }
        response = post_clancy(url: "circrequests/v1", body: body.to_json)
        if response.success?
          JSON.parse(response.body)
        else
          errors << "Error connecting with Clancy: #{response.status}"
          empty_status
        end
      end
  end
end

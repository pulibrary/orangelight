# frozen_string_literal: true
module Requests
  # FullPatron pulls all available data from both Alma and LDAP via Bibdata
  class FullPatron
    attr_reader :hash, :errors
    def initialize(uid:)
      @errors = []
      @uid = uid
      @hash = patron_hash
    end

    private

      def request_uri
        "#{Requests.config[:bibdata_base]}/patron/#{uid}?ldap=true"
      end

      def bibdata_response
        response = Faraday.get(request_uri)
        log_errors(response)
        return response if [500, 429, 404, 403].exclude?(response.status) && response.body.present?

        nil
      rescue Faraday::ConnectionFailed
        Rails.logger.error("Unable to connect to #{request_uri}")
        nil
      end

      def log_errors(response)
        case response.status
        when 500
          Rails.logger.error('Error Patron Data Service.')
        when 429
          error_message = "The maximum number of HTTP requests per second for the Alma API has been exceeded."
          Rails.logger.error(error_message)
          errors << error_message
        when 404
          Rails.logger.error("404 Patron #{uid} cannot be found in the Patron Data Service.")
        when 403
          Rails.logger.error("403 Not Authorized to Connect to Patron Data Service at #{request_uri} for patron ID #{uid}")
        else
          Rails.logger.error("#{request_uri} returned an empty patron response") if response.body.empty?
        end
      end

      # Patron hash based on the Bibdata patron API, which combines Alma and LDAP responses
      def patron_hash
        @api_response = bibdata_response
        return if api_response.blank?
        response_body = api_response.body
        JSON.parse(response_body).with_indifferent_access
      rescue JSON::ParserError
        Rails.logger.error("#{request_uri} returned an invalid patron response: #{response_body}")
        false
      end

      attr_reader :api_response, :uid
  end
end

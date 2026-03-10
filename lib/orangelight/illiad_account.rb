# frozen_string_literal: true

require 'faraday'
require 'faraday-cookie_jar'
module Orangelight
  # This class is responsible for retrieving information about an existing Interlibrary Loan account in ILLiad
  class IlliadAccount
    def initialize(patron)
      @patron = patron
    end

    def verify_user?
      return false if illiad_patron_response == false

      illiad_patron_response&.success?
    end

    def illiad_patron_response
      @illiad_patron_response ||= begin
        url = "/ILLiadWebPlatform/Users/#{netid}"
        Rails.logger.debug { "Illiad Get #{illiad_api_base}/#{url}" }
        response = conn.get do |req|
          req.url url
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
        end
        Rails.logger.debug { "Illiad Get Response #{illiad_api_base}/#{url} #{response.status} #{response.body}" }
        response
      end
    rescue Faraday::ConnectionFailed
      Rails.logger.warn("Unable to Connect to #{illiad_api_base}")
      false
    end

    private

      attr_reader :patron

      def netid
        @netid ||= patron['netid']
      end

      def illiad_api_key
        Requests.config["illiad_api_key"]
      end

      def illiad_api_base
        Requests.config["illiad_api_base"]
      end

      def conn
        @conn ||= IlliadPatronClient.new(patron).conn
      end
  end
end

# frozen_string_literal: true
require './lib/orangelight/illiad_patron_client'
require './lib/orangelight/illiad_account'

module Requests
  class IlliadClient
    attr_reader :illiad_api_base, :illiad_api_key, :error

    def initialize
      @illiad_api_key = Requests.config[:illiad_api_key].to_s
      @illiad_api_base = Requests.config[:illiad_api_base]
      @error = nil
    end

    private

      def get_json_response # rubocop:disable Naming/AccessorMethodName
        response = ::Orangelight::IlliadAccount.new(patron.patron_hash).illiad_patron_response
        return {} unless response
        data = JSON.parse(response.body)
        if response.status != 200
          if data
            Rails.logger.warn("Illiad Error Message: #{data[:message]}")
          else
            Rails.logger.warn("Illiad Error Message: #{response.reason_phrase}")
          end
          {}
        else
          data.with_indifferent_access
        end
      end

      def post_json_response(url:, body:)
        response = post_response(url:, body:)
        if response.blank? || response.status != 200
          if response.present? && response.body.present?
            Rails.logger.warn "Illiad Error Message: #{response.body}"
            @error = JSON.parse(response.body)
          else
            Rails.logger.warn "An unspecified error occurred with Illiad #{url} #{body}"
          end
          nil
        elsif response.present?
          JSON.parse(response.body)
        end
      end

      def post_response(url:, body:)
        Rails.logger.debug { "Illiad Posting #{illiad_api_base}/#{url} #{body}" }
        resp = conn.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
          req.body = body
        end
        Rails.logger.debug { "Illiad Post Response #{illiad_api_base}/#{url} #{resp.status} #{resp.body}" }
        resp
      rescue Faraday::ConnectionFailed
        Rails.logger.warn("Unable to Connect to #{@illiad_api_base}")
        nil
      end

      def conn
        @conn ||= ::Orangelight::IlliadPatronClient.new(patron:).conn
      end
  end
end

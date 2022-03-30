# frozen_string_literal: true

# require 'faraday'
# require 'faraday-cookie_jar'

module Requests
  class IlliadClient
    attr_reader :illiad_api_base, :illiad_api_key, :error

    def initialize
      @illiad_api_key = Requests::Config[:illiad_api_key].to_s
      @illiad_api_base = Requests::Config[:illiad_api_base]
      @error = nil
    end

    private

      def post_json_response(url:, body:)
        response = post_response(url: url, body: body)
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
        Rails.logger.debug("Illiad Posting #{illiad_api_base}/#{url} #{body}")
        resp = conn.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = illiad_api_key
          req.body = body
        end
        Rails.logger.debug("Illiad Post Response #{illiad_api_base}/#{url} #{resp.status} #{resp.body}")
        resp
      rescue Faraday::ConnectionFailed
        Rails.logger.warn("Unable to Connect to #{@illiad_api_base}")
        nil
      end

      def get_response(url:, body:)
        Rails.logger.debug("Illiad Get #{illiad_api_base}/#{url} #{body}")
        resp = conn.get do |req|
          req.url url
          req.headers['Accept'] = 'application/json'
          req.headers['ApiKey'] = @illiad_api_key
          req.body = body.to_json unless body.blank?
        end
        Rails.logger.debug("Illiad Get Response #{illiad_api_base}/#{url} #{resp.status} #{resp.body}")
        resp
      rescue Faraday::ConnectionFailed
        Rails.logger.warn("Unable to Connect to #{@illiad_api_base}")
        false
      end

      def get_json_response(url)
        response = get_response(url: url, body: nil)
        return {} unless response
        data = JSON.parse(response.body)
        if response.status != 200
          Rails.logger.warn("Illiad Error Message: #{data[:message]}")
          {}
        else
          data.with_indifferent_access
        end
      end

      def conn
        Faraday.new(url: @illiad_api_base.to_s) do |builder|
          # builder.use :cookie_jar
          builder.adapter Faraday.default_adapter
          builder.response :logger
        end
      end
  end
end

# frozen_string_literal: true

class Bibdata
  # This might be better derived from Faraday::ServerError
  class ServerError < StandardError; end
  class PerSecondThresholdError < StandardError; end
  class ResourceNotFoundError < StandardError; end
  class ForbiddenError < StandardError; end
  class EmptyResponseError < StandardError; end

  class << self
    # ignore rubocop warnings; complexity and length step from error checking.
    def get_patron(user, ldap:)
      return unless user.uid

      patron_uri = patron_uri(id: user.uid, ldap:)
      api_response = api_request_patron(patron_uri:)

      build_api_patron(api_response:, user:)
    rescue ServerError
      Rails.logger.error('An error was encountered with the Patron Data Service.')
      nil
    rescue PerSecondThresholdError => per_second_error
      Rails.logger.error("The maximum number of HTTP requests per second for the Alma API has been exceeded.")
      raise(per_second_error)
    rescue ResourceNotFoundError
      Rails.logger.error("404 Patron #{user.uid} cannot be found in the Patron Data Service.")
      nil
    rescue ForbiddenError
      Rails.logger.error("403 Not Authorized to Connect to Patron Data Service at #{api_base_uri}/patron/#{user.uid}")
      nil
    rescue Faraday::ConnectionFailed
      Rails.logger.error("Unable to connect to #{api_base_uri}")
      nil
    rescue EmptyResponseError
      Rails.logger.error("#{patron_uri} returned an empty patron response")
      nil
    end

    def holding_locations
      # check cache; return unless nil
      locations = Rails.cache.fetch('holding_locations', expires_in: 24.hours)
      return locations unless locations.nil?

      # don't cache if we didn't get a success
      response = Faraday.get("#{Requests.config['bibdata_base']}/locations/holding_locations.json")
      return {} unless response.status == 200

      locations = sorted_locations(response)
      Rails.cache.write('holding_locations', locations, expires_in: 24.hours)
      locations
    end

    private

      def api_base_uri
        Requests.config['bibdata_base']
      end

      def api_request_patron(patron_uri:)
        api_response = Faraday.get(patron_uri)

        case api_response.status
        when 500
          raise(ServerError)
        when 429
          raise(PerSecondThresholdError)
        when 404
          raise(ResourceNotFoundError)
        when 403
          raise(ForbiddenError)
        else
          raise(EmptyResponseError) if api_response.body.empty?
        end

        api_response
      end

      def patron_uri(id:, ldap:)
        "#{api_base_uri}/patron/#{id}?ldap=#{ldap}"
      end

      def build_api_patron(api_response:, user:)
        response_body = api_response.body
        base_patron_json = JSON.parse(response_body)
        patron_json = base_patron_json.merge(
          valid: user.valid?
        )
        patron_json.with_indifferent_access
      rescue JSON::ParserError
        Rails.logger.error("#{api_response.env.url} returned an invalid patron response: #{response_body}")
      end

      def sorted_locations(response)
        locations_hash = {}.with_indifferent_access
        JSON.parse(response.body).each do |location|
          locations_hash[location['code']] = location.with_indifferent_access
        end
        sorted = locations_hash.sort_by do |_i, l|
          [l['library']['order'], l['library']['label'], l['label']]
        end

        sorted.to_h.with_indifferent_access
      end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end

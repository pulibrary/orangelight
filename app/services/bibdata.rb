# frozen_string_literal: true

class Bibdata
  class << self
    # rubocop:disable MethodLength
    # ignore rubocop warnings; complexity and length step from error checking.
    def get_patron(id)
      return false unless id
      begin
        patron_record = Faraday.get "#{ENV['bibdata_base']}/patron/#{id}"
      rescue Faraday::Error::ConnectionFailed
        Rails.logger.info("Unable to connect to #{ENV['bibdata_base']}")
        return false
      end

      if patron_record.status == 403
        Rails.logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                    "#{ENV['bibdata_base']}/patron/#{id}")
        return false
      end
      if patron_record.status == 404
        Rails.logger.info("404 Patron #{id} cannot be found in the Patron Data Service.")
        return false
      end
      if patron_record.status == 500
        Rails.logger.info('Error Patron Data Service.')
        return false
      end
      patron = JSON.parse(patron_record.body).with_indifferent_access
      patron
    end

    def holding_locations
      # check cache; return unless nil
      locations = Rails.cache.fetch('holding_locations', expires_in: 24.hours)
      return locations unless locations.nil?

      # don't cache if we didn't get a success
      response = Faraday.get("#{ENV['bibdata_base']}/locations/holding_locations.json")
      return {} unless response.status == 200

      locations = sorted_locations(response)
      Rails.cache.write('holding_locations', locations, expires_in: 24.hours)
      locations
    end

    private

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
    # rubocop:enable MethodLength
    # rubocop:enable AbcSize
  end
end

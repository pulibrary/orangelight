require 'faraday'

# Fetches holding locations json from bibdata, and returns a sorted hash.
module HoldingLocations
  def load
    response = Faraday.get("#{ENV['bibdata_base']}/locations/holding_locations.json")
    return {} unless response.status == 200

    sorted_locations(response)
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

    module_function :load, :sorted_locations
end

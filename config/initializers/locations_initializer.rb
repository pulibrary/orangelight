# initialize location data

require 'faraday'

locations = Faraday.get("#{ENV['bibdata_base']}/locations/holding_locations.json")

unless locations.status != 200
  locations_hash = {}.with_indifferent_access
  JSON.parse(locations.body).each do |location|
    locations_hash[location['code']] = location.with_indifferent_access
  end
  sorted_locations = locations_hash.sort_by do |_i, l|
    [l['library']['order'], l['library']['label'], l['label']]
  end
  LOCATIONS = sorted_locations.to_h.with_indifferent_access
end

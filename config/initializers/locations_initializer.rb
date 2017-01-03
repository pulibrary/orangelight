# initialize location data

require 'faraday'

locations = Faraday.get("#{ENV['bibdata_base']}/locations/holding_locations.json")

unless locations.status != 200
  LOCATIONS = {}.with_indifferent_access
  JSON.parse(locations.body).each do |location|
    LOCATIONS[location['code']] = location.with_indifferent_access
  end
  LOCATIONS = LOCATIONS.sort_by do |_i, l|
    [l['library']['order'], l['library']['label'], l['label']]
  end
  LOCATIONS = LOCATIONS.to_h.with_indifferent_access
end

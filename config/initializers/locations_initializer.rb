# initialize location data

require 'faraday'

locations = Faraday.get('https://bibdata.princeton.edu/locations/holding_locations.json')

unless locations.status != 200
  LOCATIONS = {}.with_indifferent_access
  JSON.parse(locations.body).each do |location|
    LOCATIONS[location['code']] = location.with_indifferent_access
  end
end

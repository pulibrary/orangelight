# frozen_string_literal: true
def single_holding_data_from_fixture(location_code)
  file_path = File.join(fixture_paths.first, 'holding_locations', "#{location_code.tr('$', '_')}.json")
  File.read(file_path)
      .then { JSON.parse(it, symbolize_keys: true) }
end

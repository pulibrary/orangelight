# initialize holding location data
require 'holding_locations'

module Orangelight
  def locations
    @locations = HoldingLocations.load if @locations.blank?
    @locations
  end

  module_function :locations
end

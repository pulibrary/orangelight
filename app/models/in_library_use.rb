# frozen_string_literal: true
# This class is responsible for providing a label for
# in library use locations.
class InLibraryUse
  def initialize(location_code)
    @location_code = location_code
  end

  def label
    library_in_use_locations = {
      'arch$pw': "Archictecture (Remote Storage)",
      'eastasian$pl': "East Asian (Remote Storage)",
      'eastasian$ql': "East Asian (Remote Storage)",
      'engineer$pt': "Engineering (Remote Storage)",
      'firestone$pb': "Firestone (Remote Storage)",
      'firestone$pf': "Firestone (Remote Storage)",
      'lewis$pn': "Lewis (Remote Storage)",
      'lewis$ps': "Lewis (Remote Storage)",
      'mendel$pk': "Mendel (Remote Storage)",
      'mendel$qk': "Mendel (Remote Storage)",
      'stokes$pm': "Stokes (Remote Storage)",
      'marquand$pj': "Marquand (Remote Storage)",
      'marquand$pjm': "Marquand (Remote Storage)",
      'marquand$pv': "Marquand (Remote Storage)",
      'marquand$pz': "Marquand (Remote Storage)"
    }.freeze
    library_in_use_locations[location_code&.to_sym]
  end

    private

      attr_reader :location_code
end

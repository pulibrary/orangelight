# frozen_string_literal: true

# This component is responsible for displaying an SVG icon
# that corresponds to the provided format string.
#
# It should only be used for decorative icons that have a
# text alternative close
class DecorativeFormatIconComponent < ViewComponent::Base
  def initialize(format)
    @format = format
  end

    private

      attr_reader :format

      def render?
        [
          'Audio',
          'Archival item',
          'Book',
          'Coin',
          'Databases',
          'Data file',
          'Journal',
          'Manuscript',
          'Map',
          'Microform',
          'Musical score',
          'Senior thesis',
          'Video/Projected medium',
          'Visual material'
        ].include? format
      end
end

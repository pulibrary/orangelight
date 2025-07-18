# frozen_string_literal: true

# This component is responsible for displaying an SVG icon
# that corresponds to the provided access string.
#
# It should only be used for decorative icons that have a
# text alternative close
class DecorativeAccessIconComponent < ViewComponent::Base
  def initialize(access)
    @access = access
  end

    private

      attr_reader :access

      def render?
        [
          'Physical',
          'Online'
        ].include? access
      end
end

# frozen_string_literal: true
module Orangelight
  module System
    class FlashMessageComponent < Blacklight::System::FlashMessageComponent
      def initialize(type:, message: nil)
        super
        @type = type
      end

        private

          def lux_status
            @lux_status ||= { 'success' => 'success',
                              'notice' => 'info',
                              'alert' => 'warning',
                              'error' => 'error' }[@type.to_s] || 'info'
          end
    end
  end
end

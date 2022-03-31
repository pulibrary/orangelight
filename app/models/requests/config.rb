# frozen_string_literal: true
module Requests
  class Config
    class << self
      delegate :[], to: :config

      def recap_partner_location_codes
        config[:recap_partner_locations].keys
      end

      private

        def config
          Requests.config
        end
    end
  end
end

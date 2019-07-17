# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Barcode
      include OmniAuth::Strategy
      include ActionView::Helpers::FormHelper

      option :fields, %i[last_name barcode]
      option :uid_field, :barcode

      uid do
        request.params[options.uid_field.to_s]
      end

      info do
        hash = {}
        last_name = request.params['last_name'] || ''
        hash[:last_name] = last_name.downcase.capitalize
        hash
      end

      def request_phase
        redirect '/users/sign_in'
      end
    end
  end
end

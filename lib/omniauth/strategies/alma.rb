# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Alma
      include OmniAuth::Strategy
      include ActionView::Helpers::FormHelper

      option :fields, %i[username]
      option :uid_field, :username

      uid do
        request.params[options.uid_field.to_s]
      end

      info do
        {}
      end

      def request_phase
        redirect '/users/sign_in'
      end
    end
  end
end

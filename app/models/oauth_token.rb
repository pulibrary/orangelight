# frozen_string_literal: true

# This class is responsible for persisting
# OAuth tokens to the database
class OAuthToken < ApplicationRecord
  def token
    if expiration_time && not_yet_expired?
      self[:token]
    else
      fetch_new_token
      reload[:token]
    end
  end

    private

      def fetch_new_token
        service = OAuthService.new(service: self.service, endpoint:)
        self.token = service.new_token
        self.expiration_time = service.expiration_time
        save
      end

      def not_yet_expired?
        (Time.zone.now < expiration_time)
      end
end

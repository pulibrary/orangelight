# frozen_string_literal: true
module Requests
  # Create a Patron from session information
  class AccessPatron
    attr_reader :user_name, :email
    def initialize(session:)
      @user_name = session["user_name"]
      @email = session["email"]
    end

    def hash
      {
        last_name: user_name,
        active_email: email,
        barcode: 'ACCESS',
        barcode_status: 0
      }.with_indifferent_access
    end
  end
end

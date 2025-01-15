# frozen_string_literal: true
module Requests
  # FullPatron pulls all available data from both Alma and LDAP via Bibdata
  class FullPatron
    attr_reader :patron_hash
    def initialize(user: nil)
      @patron_hash = ::Bibdata.get_patron(user, ldap: true)
    end
  end
end

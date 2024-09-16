# frozen_string_literal: true
module Requests
  # FullPatron pulls all available data from both Alma and LDAP via Bibdata
  class FullPatron
    attr_reader :hash
    def initialize(user: nil)
      @hash = ::Bibdata.get_patron(user, ldap: true)
    end
  end
end

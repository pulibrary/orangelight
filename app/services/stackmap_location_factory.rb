# frozen_string_literal: true

class StackmapLocationFactory
  # Constructor
  # @param resolver_service [Class] API for the resolution service
  def initialize(resolver_service:)
    @resolver_service = resolver_service
  end

  # Checks to see if provided holding info should resolve to a stackmap url
  # @param call_number [String] the call number for the holding
  # @param library [String] the library in which the holding is located
  # @return [Boolean] Exclude stackmap url if return value is true
  def exclude?(call_number:, library:)
    excluded?(library) || call_number?(call_number, library)
  end

  private

    # Whether or not a library should exclude a holding from having its location resolved
    # @param library [String] the library in which the holding resides
    # @return [TrueClass, FalseClass]
    def excluded?(library)
      [
        'Fine Annex',
        'Forrestal Annex',
        'Mudd Manuscript Library',
        'Online',
        'Rare Books and Special Collections',
        'ReCAP',
        'Lewis Library' # Temporarily inaccessible
      ].include?(library)
    end

    # Exclude the stackmap link for records without call numbers,
    # unless they are in Firestone (other locator works without a call number)
    def call_number?(call_number, library)
      call_number.nil? && library != 'Firestone Library'
    end
end

# frozen_string_literal: true
# We can remove this service (and just call search_service directly)
# after we migrate to Blacklight 8
# :reek:UncommunicativeVariableName
class SearchServiceCompatibilityWrapper
  def initialize(search_service)
    @search_service = search_service
  end

  # :reek:DuplicateMethodCall
  # :reek:FeatureEnvy
  def fetch(...)
    if using_blacklight7?
      _response, document = search_service.fetch(...)
      document
    else
      search_service.fetch(...)
    end
  end

  # :reek:DuplicateMethodCall
  # :reek:FeatureEnvy
  def search_results(...)
    if using_blacklight7?
      search_service.search_results(...).first
    else
      search_service.search_results(...)
    end
  end

  private

    attr_reader :search_service

    def using_blacklight7?
      @using_blacklight7 ||= Gem.loaded_specs['blacklight'].version.to_s.start_with? '7'
    end
end
# frozen_string_literal: true
# We can remove this service (and just call search_service.fetch directly)
# after we migrate to Blacklight 8
class RetrieveRecordService
  # :reek:DuplicateMethodCall
  # :reek:FeatureEnvy
  def retrieve(search_service, ...)
    if using_blacklight7?
      _response, document = search_service.fetch(...)
      document
    else
      search_service.fetch(...)
    end
  end

  private

    # :reek:UtilityFunction
    def using_blacklight7?
      Gem.loaded_specs['blacklight'].version.to_s.start_with? '7'
    end
end

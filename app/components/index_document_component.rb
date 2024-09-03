# frozen_string_literal: true

class IndexDocumentComponent < Blacklight::DocumentComponent
  private

    # TODO: Delete this method after we migrate to Blacklight 8
    def using_blacklight7
      Gem.loaded_specs['blacklight'].version.to_s.start_with? '7'
    end

    def action
      presenter.configuration&.index&.document_actions&.bookmark
    end
end

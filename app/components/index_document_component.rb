# frozen_string_literal: true

class IndexDocumentComponent < Blacklight::DocumentComponent
  private

    def action
      presenter.configuration&.index&.document_actions&.bookmark!
    end
end

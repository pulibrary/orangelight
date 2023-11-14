# frozen_string_literal: true
module Orangelight
  class HighlightPresenter < Blacklight::FieldPresenter
    def initialize(view_context, document, field_config, options = {})
      super
      @field_config["highlight"] = Flipflop.highlighting?
    end
  end
end

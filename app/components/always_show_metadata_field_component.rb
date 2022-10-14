# frozen_string_literal: true
class AlwaysShowMetadataFieldComponent < Blacklight::MetadataFieldComponent
  def render?
    true
  end
end

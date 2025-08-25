##
# ViewerComponent
#
# This component is responsible for rendering a viewer for ephemera items using IIIF manifests.
# It expects an `electronic_access_1display` parameter containing JSON with IIIF manifest paths.
# The component extracts the ephemera manifest URL for use in the view.
#
# Example usage:
#   render(ViewerComponent.new(electronic_access_1display: ...))
#
# The manifest_url method returns the IIIF manifest URL for the ephemera item, or nil if not available.
#
# frozen_string_literal: true
class ViewerComponent < ViewComponent::Base
  require 'json'

  def initialize(electronic_access_1display:)
    @electronic_access_1display = electronic_access_1display
  end

  def manifest_url
    return '{}' if @electronic_access_1display.blank?
    return unless iiif_manifest_paths
    iiif_manifest_paths
  end

  private

    def iiif_manifest_paths
      return {} if @electronic_access_1display.blank?
      data = JSON.parse(@electronic_access_1display)
      data['iiif_manifest_paths'].values
    end
end

class ViewerComponent < ViewComponent::Base
    require 'json'

    def initialize(electronic_access_1display:)
        @electronic_access_1display = electronic_access_1display
    end

    def manifest_url
        return nil if @electronic_access_1display.blank?
        data = JSON.parse(@electronic_access_1display)
        if data['iiif_manifest_paths'] && data['iiif_manifest_paths']['ephemera_ark']
            return data['iiif_manifest_paths']['ephemera_ark']
        end
    end
end

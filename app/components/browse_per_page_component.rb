class BrowsePerPageComponent < Blacklight::Search::PerPageComponent
    def render?
        true
    end

    def initialize(
        blacklight_config:,
        response:,
        search_state:,
        current_browse_per_page:
        )
        super(blacklight_config:, response:, search_state:)
        @current_browse_per_page = current_browse_per_page
    end

    def current_per_page
        return @current_browse_per_page
    end
end
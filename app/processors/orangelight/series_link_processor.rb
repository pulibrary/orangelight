# frozen_string_literal: true
module Orangelight
  class SeriesLinkProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper

    def render
      return next_step(values) unless config.series_link
      values.map! do |title|
        # rubocop:disable Rails/OutputSafety
        title = "#{title} #{more_in_this_series_link(title)}".html_safe if more_in_this_series_field_contains? title
        # rubocop:enable Rails/OutputSafety
        title
      end
      next_step(values)
    end

    private

      # Generate a query link for all items within a given series using a title
      # @param title [String] the title of the series
      # @return [String] the link markup
      def more_in_this_series_link(title)
        link_to('[More in this series]', advanced_search_series_link(title),
                class: 'more-in-series',
                'data-original-title' => "More in series: #{title}",
                dir: title.dir.to_s)
      end

      def advanced_search_series_link(title)
        no_parens = authorized_form_of_title(title).gsub(/[()]/, '')
        if Flipflop.json_query_dsl?
          path = '/catalog'
          query = {
            "clause[0][field]": 'series_title',
            "clause[0][query]": no_parens,
            "commit": "Search"
          }.to_query
          URI::HTTP.build(path:, query:).request_uri
        else
          "/catalog?q1=#{CGI.escape no_parens}&f1=in_series&search_field=advanced"
        end
      end

      def more_in_this_series_field_contains?(title)
        document['more_in_this_series_t'].present? && authorized_form_of_title(title)
      end

      def authorized_form_of_title(title)
        document['more_in_this_series_t'].find { |series_title| title.starts_with?(series_title) }
      end
  end
end

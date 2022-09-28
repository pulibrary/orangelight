# frozen_string_literal: true

module Orangelight
  class BrowseLinkProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper

    def render
      return next_step(values) unless config.browse_link

      next_step(values.map { |value| add_links_to value })
    end

    private

      def facet_field
        case config.browse_link
        when :name
          'author_s'
        when :name_title
          'name_title_browse_s'
        end
      end

      def browse_path
        "#{config.browse_link}s"
      end

      def search_class
        "search-#{config.browse_link.to_s.tr('_', '-')}"
      end

      def browse_class
        "browse-#{config.browse_link.to_s.tr('_', '-')}"
      end

      def add_links_to(value)
        return value unless should_render_links?(value)
        link_to(value, "/?f[#{facet_field}][]=#{CGI.escape value}", class: search_class, 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{value}", title: "") + ' ' +
          link_to('[Browse]', "/browse/#{browse_path}?q=#{CGI.escape value}", class: browse_class, 'data-toggle' => 'tooltip', 'data-original-title' => "Browse: #{value}", title: "", dir: value.dir.to_s)
      end

      def should_render_links?(value)
        return true unless config.browse_link == :name_title
        document['name_title_browse_s']&.include? value
      end
  end
end

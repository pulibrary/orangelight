# frozen_string_literal: true
module Orangelight
  class AuthorTitleLinksProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper

    def render
      if config.author_title_links
        next_step linked
      else
        next_step values
      end
    end

    private

      # :reek:NestedIterators
      # :reek:TooManyStatements
      def linked
        values.map do |raw|
          parsed = JSON.parse(raw)
          parsed.map do |heading|
            full_name_title = heading.join(' ')
            with_links = heading.each_with_index.map do |part, index|
              # The author is the first entry in the array.
              is_author = index.zero?
              next if config.no_author_link && is_author

              field = is_author ? 'author_s' : 'name_title_browse_s'
              search_query = StringFunctions.trim_punctuation(heading[0..index].join(' '))
              link_to part, "/?f[#{field}][]=#{CGI.escape search_query}", class: 'search-name-title', dir: part.dir
            end
            (with_links + [link_to('[Browse]', "/browse/name_titles?q=#{CGI.escape full_name_title}", class: 'browse-name-title', dir: full_name_title.dir)])
              .join(' ')
              .html_safe # rubocop:disable Rails/OutputSafety
          end
        end.flatten
      end
  end
end

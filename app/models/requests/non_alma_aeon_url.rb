# frozen_string_literal: true
module Requests
  # Create a URL that creates an aeon request
  class NonAlmaAeonUrl < AeonUrl
    private

      def aeon_basic_params
        super.merge({
                      Action: 10,
                      Form: 21,
                      ItemTitle: aeon_title.truncate(247),
                      ItemAuthor: author,
                      ItemDate: @document[:pub_date_start_sort],
                      ItemVolume: @holding[:location],
                      genre:
                    }).compact
      end

      def aeon_title
        "#{@document.first(:title_display)}#{title_genre}"
      end

      ## Don T requested this be appended when present
      def title_genre
        " [ #{@document.first(:form_genre_display)} ]" unless @document[:form_genre_display].nil?
      end

      def genre
        return 'numismatics' if holding[:call_number]&.downcase&.start_with?('coin')
        'thesis'
      end

      def author
        @document[:author_display]&.join(" AND ")
      end
  end
end

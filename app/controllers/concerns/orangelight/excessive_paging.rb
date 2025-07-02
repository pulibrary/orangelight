# frozen_string_literal: true
module Orangelight
  module ExcessivePaging
    private

      def deny_excessive_paging
        # rubocop:disable Lint/UselessOr
        page = params[:page].to_i || 0
        # rubocop:enable Lint/UselessOr
        return if page <= 1
        return if (has_search_parameters? || advanced_search? || bookmarks_page?) && page < 1000
        render plain: "excessive paging", status: :bad_request
      end

      def advanced_search?
        %w[advanced numismatics].include?(params[:advanced_type]) ||
          params[:search_field] == 'advanced' ||
          %w[advanced numismatics].include?(action_name)
      end

      def bookmarks_page?
        instance_of?(BookmarksController)
      end
  end
end

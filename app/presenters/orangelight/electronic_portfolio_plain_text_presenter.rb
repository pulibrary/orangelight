# frozen_string_literal: true
module Orangelight
  # This class is responsible for presenting electronic portfolio data from solr documents
  # in a way suitable for plain text settings, like a plain text email
  class ElectronicPortfolioPlainTextPresenter < Blacklight::FieldPresenter
    def values
      super.map { |access_point| format_access_point(access_point) }
    end

    private

      # :reek:DuplicateMethodCall
      # :reek:UtilityFunction
      def format_access_point(access_point)
        portfolio = JSON.parse(access_point)
        "\t#{portfolio['title']}: #{portfolio['url']}\n"
      end
  end
end

# frozen_string_literal: true
module Orangelight
  # This class is responsible for presenting electonic access data from solr documents
  # in a way suitable for plain text settings, like a plain text email
  class ElectronicAccessPlainTextPresenter < Blacklight::FieldPresenter
    def values
      super.map { |access_point| format_access_point(access_point) }
    end

    private

      # :reek:DuplicateMethodCall
      # :reek:UtilityFunction
      def format_access_point(access_point)
        JSON.parse(access_point).reduce('') do |accumulator, (url, text)|
          link = "#{text[0]}: #{url}"
          link = "#{text[1]} - " + link if text[1]
          accumulator + "\t#{link}"
        end
      end
  end
end

# frozen_string_literal: true
module Orangelight
  # This class is responsible for presenting holdings data from solr documents
  # in a way suitable for plain text settings, like a plain text email
  class HoldingsPlainTextPresenter < Blacklight::FieldPresenter
    # :reek:FeatureEnvy
    # :reek:DuplicateMethodCall
    # :reek:TooManyStatements
    def values
      super.map do |holding|
        holdings_data = JSON.parse(holding).values.first
        location_statement = "\n\tLocation: #{holdings_data['library']}"
        location_statement << " - #{holdings_data['location']}" if holdings_data['location']
        location_statement << "\n\tCall number: #{holdings_data['call_number']}" if holdings_data['call_number']
        location_statement
      end
    end
  end
end

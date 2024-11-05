# frozen_string_literal: true

# A View Component that is responsible for formatting a record's holdings
# (including bound-with holdings) in a way suitable for plain-text contexts,
# like a plain-text email.
class Holdings::PlainTextComponent < ViewComponent::Base
  def initialize(document)
    @document = document
  end

  def call
    return if formatted_holdings_data.blank?
    "Holdings:\n#{formatted_holdings_data}"
  end

  private

    # :reek:DuplicateMethodCall
    # :reek:FeatureEnvy
    def formatted_holdings_data
      @formatted_holdings_data ||= document.holdings_all_display&.values&.map do |holdings_data|
        location_statement = "\n\tLocation: #{holdings_data['library']}"
        location_statement << " - #{holdings_data['location']}" if holdings_data['location']
        location_statement << "\n\tCall number: #{holdings_data['call_number']}" if holdings_data['call_number']
        location_statement
      end&.join("\n")
    end
    attr_reader :document
end

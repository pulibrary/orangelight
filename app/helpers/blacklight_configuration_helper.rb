# frozen_string_literal: true

module BlacklightConfigurationHelper
  include Blacklight::ConfigurationHelperBehavior

  ##
  # Overrides method to always return label, including all_fields
  # Return a label for the currently selected search field.
  # If no "search_field" or the default (e.g. "all_fields") is selected, then return nil
  # Otherwise grab the label of the selected search field.
  # @param [Hash] query parameters
  # @return [String]
  def constraint_query_label(localized_params = params)
    label_for_search_field(localized_params[:search_field])
  end
end

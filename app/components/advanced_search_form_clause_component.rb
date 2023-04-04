# frozen_string_literal: true

# A component that presents a single search field in the
# advanced search form, along with its operator and
# a dropdown to select which field you'd like to search
class AdvancedSearchFormClauseComponent < ViewComponent::Base
  def initialize(index:, default:, search_fields:)
    @index = index
    @default = default
    @search_fields = search_fields
  end

  def default_field
    @default
  end
end

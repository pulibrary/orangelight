# frozen_string_literal: true
class DeprecatedAdvancedSearchConstraint
  def matches?(_request)
    !Flipflop.view_components_advanced_search?
  end
end

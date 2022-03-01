# frozen_string_literal: true
class GuidedSearchConstraintsComponent < ViewComponent::Base
  renders_many :constraints, Blacklight::ConstraintLayoutComponent
end

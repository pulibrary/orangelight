# frozen_string_literal: true

# This component is responsible for displaying a group
# of physical holdings
class Holdings::PhysicalHoldingGroupComponent < ViewComponent::Base
  # :reek:BooleanParameter
  def initialize(group:, adapter:, open: false)
    @group = group
    @adapter = adapter
    @open = open
  end

    private

      attr_reader :adapter, :group, :open
end

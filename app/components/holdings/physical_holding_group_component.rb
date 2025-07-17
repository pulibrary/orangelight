# frozen_string_literal: true

# This component is responsible for displaying a group
# of physical holdings
class Holdings::PhysicalHoldingGroupComponent < ViewComponent::Base
  def initialize(group:, adapter:, index: 0)
    @group = group
    @adapter = adapter
    @index = index
  end

    private

      def open_by_default?
        # The first group should be open by default
        @index.zero?
      end

      attr_reader :adapter, :group
end

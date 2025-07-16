# frozen_string_literal: true

# This component is responsible for rendering a SCSB holding's availability
# (which will be provided by Javascript based on the DOM structure of
# this component)
class Holdings::HoldingAvailabilityScsbComponent < ViewComponent::Base
  def initialize(holding, doc_id, holding_id)
    @holding = holding
    @doc_id = doc_id
    @holding_id = holding_id
  end

    private

      attr_reader :holding, :doc_id, :holding_id

      def scsb_supervised_items?
        if holding.key? 'items'
          restricted_items = items.select do |item|
            item['use_statement'] == 'Supervised Use'
          end
          restricted_items.count == items.count
        else
          false
        end
      end

      def items
        @items ||= holding['items']
      end
end

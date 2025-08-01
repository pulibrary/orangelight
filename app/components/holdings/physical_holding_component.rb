# frozen_string_literal: true

# This component is responsible for showing the details of a physical
# holding (such as on the show page)
class Holdings::PhysicalHoldingComponent < ViewComponent::Base
  def initialize(adapter, holding_id, holding, open_holdings = nil)
    @adapter = adapter
    @holding_id = holding_id
    @holding = holding
    @open_holdings = open_holdings
  end

  private

    attr_reader :adapter, :holding_id, :holding, :open_holdings

    def cn_value
      adapter.call_number(holding)
    end

    def doc_id
      holding["mms_id"] || adapter.doc_id
    end

    def location_rules
      adapter.holding_location_rules(holding)
    end

    def temp_location_code
      adapter.temp_location_code(holding)
    end
end

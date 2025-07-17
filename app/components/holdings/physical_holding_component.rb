# frozen_string_literal: true
class Holdings::PhysicalHoldingComponent < ViewComponent::Base
  def initialize(adapter, holding_id, holding)
    @adapter = adapter
    @holding_id = holding_id
    @holding = holding
  end

  private

    attr_reader :adapter, :holding_id, :holding

    def cn_value
      adapter.call_number(holding)
    end

    def doc_id
      holding["mms_id"] || adapter.doc_id
    end

    def holding_loc
      adapter.holding_location_label(holding)
    end

    # rubocop:disable Rails/OutputSafety
    def holding_location_unavailable
      children = content_tag(:span,
                             'Unavailable',
                             class: 'availability-icon badge bg-danger')
      content_tag(:td, children.html_safe, class: 'holding-status')
    end

    def holding_location_repository
      children = content_tag(:span,
                             'On-site access',
                             class: 'availability-icon badge bg-success')
      content_tag(:td, children.html_safe)
    end
    # rubocop:enable Rails/OutputSafety

    def location_rules
      adapter.holding_location_rules(holding)
    end

    def temp_location_code
      adapter.temp_location_code(holding)
    end
end

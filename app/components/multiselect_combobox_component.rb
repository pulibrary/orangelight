# frozen_string_literal: true

class MultiselectComboboxComponent < ViewComponent::Base
  def initialize(label:, dom_id:, values:, field_name:)
    @label = label
    @dom_id = dom_id
    @values = values
    @field_name = field_name
    @listbox_id = "#{dom_id}-list"
    @hidden_select_id = "#{dom_id}-select"
  end
end

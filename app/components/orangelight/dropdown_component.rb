# frozen_string_literal: true

class Orangelight::DropdownComponent < ViewComponent::Base
  def initialize(label:, actions: [])
    @label = label
    @actions = actions
  end

  attr_reader :label, :actions
end

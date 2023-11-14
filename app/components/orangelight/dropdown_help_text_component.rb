# frozen_string_literal: true

class Orangelight::DropdownHelpTextComponent < Blacklight::System::DropdownComponent
  # options are { label:, value:, helptext: } hashes
  def option_text_and_value(option)
    [option[:label], option[:value]]
  end

  # Override to allow adding and styling a helptext for each option
  def before_render
    with_button(classes: 'btn btn-outline-secondary dropdown-toggle', label: button_label) unless button

    return if options.any?

    with_options(@choices.map do |option|
      value = option[:value]
      { text: label_text(option), url: helpers.url_for(@search_state.params_for_search(@param => value)), selected: @selected == value }
    end)
  end

  def label_text(option)
    content_tag(:div) do
      safe_join(
        [
          content_tag(:div, option[:label]),
          content_tag(:div, option[:helptext], id: option[:value], class: "dropdown-help-text")
        ]
      )
    end
  end
end

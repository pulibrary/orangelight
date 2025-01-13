# frozen_string_literal: true

class Orangelight::FacetFieldCheckboxesComponent < Blacklight::FacetFieldCheckboxesComponent
  def values
    presenters.map do |presenter|
      {
        value: presenter.value,
        selected: presenter.selected?,
        label: "#{presenter.label}  (#{number_with_delimiter presenter.hits})"
      }
    end
  end
end

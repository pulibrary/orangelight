# frozen_string_literal: true

class Orangelight::FacetFieldCheckboxesComponent < Blacklight::FacetFieldCheckboxesComponent
  def values
    presenters.map do |presenter|
      {
        value: presenter.value,
        selected: presenter.search_state.filter(presenter.facet_config).include?([presenter.value]),
        label: "#{presenter.label}  (#{number_with_delimiter presenter.hits})"
      }
    end
  end
end

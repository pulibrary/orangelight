# frozen_string_literal: true

class Orangelight::FacetFieldCheckboxesComponent < Blacklight::FacetFieldCheckboxesComponent
  delegate :paginator, to: :facet_field
  def presenters
    return [] unless paginator

    return to_enum(:presenters) unless block_given?

    paginator.items.each do |item|
      yield checkbox_presenter_class.new(item, facet_field.facet_field, helpers, facet_field.key, facet_field.search_state)
    end
  end

  def values
    presenters.map do |presenter|
      {
        value: presenter.value,
        selected: presenter.selected?,
        label: "#{presenter.label}  (#{number_with_delimiter presenter.hits})"
      }
    end
  end

  private

    attr_reader :facet_field

    def checkbox_presenter_class
      facet_field&.facet_field&.checkbox_presenter || Blacklight::FacetCheckboxItemPresenter
    end
end

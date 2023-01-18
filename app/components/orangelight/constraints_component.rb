# frozen_string_literal: true

class Orangelight::ConstraintsComponent < Blacklight::ConstraintsComponent
  # rubocop:disable Metrics/ParameterLists
  def initialize(search_state:,
                 tag: :div,
                 render_headers: true,
                 id: 'appliedParams', classes: 'clearfix constraints-container',
                 query_constraint_component: Blacklight::ConstraintLayoutComponent,
                 query_constraint_component_options: {},
                 facet_constraint_component: Orangelight::ConstraintComponent,
                 facet_constraint_component_options: {},
                 start_over_component: Blacklight::StartOverButtonComponent)
    super
  end
  # rubocop:enable Metrics/ParameterLists

  def query_constraints
    super + guided_search_constraints
  end

  def remove_guided_query_path(index)
    url_for @search_state.to_h.reject { |k, _v| k.match?(/[f|q|op]#{index}/) }
  end

  def render?
    super || @search_state.to_h.keys.any? { |param| param.match?(/[f|q|op][1-3]/) }
  end

  private

    def guided_search_constraints
      constraints_string = ''.html_safe
      (1..3).each do |index|
        constraints_string += helpers.render(
          @query_constraint_component.new(
            search_state: @search_state,
            value: guided_search_value(index),
            label: guided_search_label(index),
            remove_path: remove_guided_query_path(index),
            classes: 'query',
            **@query_constraint_component_options
          )
        )
      end
      constraints_string
    end

    def guided_search_value(index)
      params = @search_state.to_h
      return if params[:"q#{index}"].blank?

      has_operator = params[:"op#{index}"].present?
      prefix = has_operator ? params[:"op#{index}"].upcase + ' ' : ''
      prefix + params[:"q#{index}"]
    end

    def guided_search_label(index)
      search_field = @search_state.params[:"f#{index}"]
      helpers.label_for_search_field(search_field) unless helpers.default_search_field?(search_field)
    end
end

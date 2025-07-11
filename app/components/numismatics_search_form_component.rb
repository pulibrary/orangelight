# frozen_string_literal: true

class NumismaticsSearchFormComponent < Blacklight::AdvancedSearchFormComponent
  private

    def initialize_search_filter_controls
      fields = ['issue_object_type_s', 'issue_denomination_s',
                'issue_metal_s', 'issue_city_s', 'issue_state_s',
                'issue_region_s', 'issue_ruler_s',
                'issue_artists_s', 'find_place_s'].map do |field_name|
        blacklight_config.facet_fields[field_name]
      end.compact

      fields.each do |config|
        config.advanced_search_component = Orangelight::FacetFieldCheckboxesComponent
        display_facet = @response.aggregations[config.field]
        with_search_filter_control(config:, display_facet:)
      end
    end

    def pub_date_field
      blacklight_config.facet_fields['pub_date_start_sort']
    end

    def pub_date_field_display_facet
      @response.aggregations[pub_date_field]
    end

    def pub_date_presenter
      view_context.facet_field_presenter(pub_date_field, pub_date_field_display_facet)
    end

    def initialize_constraints
      params = helpers.search_state.params_for_search.except :page, :q, :search_field, :op, :index, :sort

      adv_search_context = helpers.search_state.reset(params)

      constraints_text = render(Blacklight::ConstraintsComponent.for_search_history(search_state: adv_search_context))

      return if constraints_text.blank?

      with_constraint do
        constraints_text
      end
    end

    def hidden_search_state_params
      @params.except(:clause, :f_inclusive, :op, :sort).merge({ 'advanced_type' => 'numismatics' })
    end
end

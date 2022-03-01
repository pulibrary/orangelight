# frozen_string_literal: true

# Override the upstream Blacklight constraints component to
# include our customizations
class ConstraintsComponent < Blacklight::ConstraintsComponent
  def guided_search_constraints
    constraints = []
    if @search_state.params[:q1].present? && @search_state.params[:f1].present?
      label = helpers.blacklight_config.search_fields[@search_state.params[:f1]].try(:label)
      if label
        query = @search_state.params[:q1]
        constraints << {
          label:, value: query,
          remove_path: search_catalog_path(remove_guided_keyword_query(%i[f1 q1], @search_state.params))
        }
      end
    end
    if @search_state.params[:q2].present? && @search_state.params[:f2].present?
      label = helpers.blacklight_config.search_fields[@search_state.params[:f2]].try(:label)
      if label
        query = @search_state.params[:q2]
        query = 'NOT ' + @search_state.params[:q2] if @search_state.params[:op2] == 'NOT'
        constraints << {
          label:, value: query,
          remove_path: search_catalog_path(remove_guided_keyword_query(%i[f2 q2 op2], @search_state.params))
        }
      end
    end
    if @search_state.params[:q3].present? && @search_state.params[:f3].present?
      label = helpers.blacklight_config.search_fields[@search_state.params[:f3]].try(:label)
      if label
        query = @search_state.params[:q3]
        query = 'NOT ' + @search_state.params[:q3] if @search_state.params[:op3] == 'NOT'
        constraints << {
          label:, value: query,
          remove_path: search_catalog_path(remove_guided_keyword_query(%i[f3 q3 op3], @search_state.params))
        }
      end
    end
    constraints
  end

  private

    def remove_guided_keyword_query(fields, my_params = params)
      my_params = Blacklight::SearchState.new(my_params, helpers.blacklight_config).to_h
      fields.each do |guided_field|
        my_params.delete(guided_field)
      end
      my_params
    end
end

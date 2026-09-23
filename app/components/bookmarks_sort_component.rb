# frozen_string_literal: true

class BookmarksSortComponent < Blacklight::Component
  def initialize(search_state:, param: 'sort', choices: {}, id: 'sort-dropdown', classes: [], selected: 'score desc')
    @param = param
    @choices = add_recently_bookmarked_sort_option(choices)
    @search_state = search_state
    @id = id
    @classes = classes
    @selected = selected
  end

  def dropdown_class
    helpers.blacklight_config.view_config(:show).dropdown_component
  end

  def dropdown
    render(dropdown_class.new(
              param: @param,
              choices: @choices,
              id: @id,
              classes: @classes,
              search_state: @search_state,
              selected: @selected
            ))
  end

  private

  def add_recently_bookmarked_sort_option(choices)
    if choices[0][0] = 'relevance'
      choices.unshift(['recently bookmarked', 'score desc'])
      @selected = 'score desc'
    end
    choices
  end
end
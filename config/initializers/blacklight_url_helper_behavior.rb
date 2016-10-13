Blacklight::UrlHelperBehavior.module_eval do
  # Link to the previous document in the current search context
  def link_to_previous_document(previous_document)
    link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
    link_to_unless previous_document.nil?, raw(t('blacklight.pagination_compact.previous').html_safe), url_for_document(previous_document), link_opts do
      content_tag :span, raw(t('blacklight.pagination_compact.previous').html_safe), :class => 'previous'
    end
  end

  # Link to the next document in the current search context
  def link_to_next_document(next_document)
    link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
    link_to_unless next_document.nil?, raw(t('blacklight.pagination_compact.next').html_safe), url_for_document(next_document), link_opts do
      content_tag :span, raw(t('blacklight.pagination_compact.next').html_safe), :class => 'next'
    end
  end

  # Create a link back to the index screen, keeping the user's facet, query and paging choices intact by using session.
  # @example
  #   link_back_to_catalog(label: 'Back to Search')
  #   link_back_to_catalog(label: 'Back to Search', route_set: my_engine)
  def link_back_to_catalog(opts={:label=>nil})
    scope = opts.delete(:route_set) || self
    query_params = current_search_session.try(:query_params) || ActionController::Parameters.new

    if search_session['counter']
      per_page = (search_session['per_page'] || default_per_page).to_i
      counter = search_session['counter'].to_i

      query_params[:per_page] = per_page unless search_session['per_page'].to_i == default_per_page
      query_params[:page] = ((counter - 1)/ per_page) + 1
    end

    link_url = if query_params.empty?
      search_action_path(only_path: true)
    else
      scope.url_for(query_params)
    end
    label = opts.delete(:label)

    if link_url =~ /bookmarks/
      label ||= t('blacklight.back_to_bookmarks')
    end

    label ||= t('blacklight.back_to_search').html_safe

    link_to label, link_url, opts
  end
end

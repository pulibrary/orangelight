# frozen_string_literal: false

# rubocop:disable Metrics/ModuleLength
module HoldingsHelper
  # Generate the markup block for individual search result items containing holding information
  # @param document [SolrDocument] the Solr Document retrieved in the search result set
  # @return [String] the markup

  def holding_block_search(document)
    block = ''.html_safe
    links = holding_block_search_links(document)
    holdings_hash = document.holdings_all_display
    @scsb_multiple = false

    holdings_hash.first(2).each do |id, holding|
      block << first_two_holdings_block(document, id, holding, links)
      block << content_tag(:li, cdl_placeholder)
    end

    if @scsb_multiple == true
      block << view_record_for_full_avail_li(document)
    elsif holdings_hash.length > 2
      block << additional_holdings_span
    elsif !holdings_hash.empty?
      block << view_record_for_full_avail_li_two(document)
    end

    if block.empty? && links.present?
      # All other options came up empty but since we have electronic access let's show the
      # Online badge with the electronic access link (rather than a misleading "No holdings")
      block << content_tag(:li, online_holding_block(links))
    end

    if block.empty?
      content_tag(:div, t('blacklight.holdings.search_missing'))
    else
      content_tag(:ul, block)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # Currently having trouble breaking up this method further due to the "check_availability" variable
  def first_two_holdings_block(document, id, holding, links)
    location = holding_location(holding)
    check_availability = render_availability?
    accumulator = ''.html_safe
    if holding['library'] == 'Online'
      check_availability = false
      if links.empty?
        check_availability = render_availability?
        accumulator << empty_link_online_holding_block
      else
        accumulator << online_holding_block(links)
      end
    else
      if holding['dspace'] || holding['location_code'] == 'rare$num'
        check_availability = false
        accumulator << dspace_or_numismatics_holding_block(location)
      elsif /^scsb.+/.match? location[:code]
        check_availability = false
        unless holding['items'].nil?
          @scsb_multiple = true unless holding['items'].count == 1
          accumulator << scsb_item_block(holding)
        end
      elsif holding['dspace'].nil?
        accumulator << dspace_not_defined_block(location)
      else
        check_availability = false
        accumulator << under_embargo_block
      end
      accumulator << library_location_div(holding, document, id)
    end
    holding_status_li(accumulator, document, check_availability, id, holding)
  end
  # rubocop:enable Metrics/MethodLength

  def holding_block_search_links(document)
    portfolio_links = electronic_portfolio_links(document)
    search_links = search_links(document['electronic_access_1display'])
    search_links + portfolio_links
  end

  def empty_link_online_holding_block
    data = content_tag(
      :span,
      'Link Missing',
      class: 'availability-icon badge badge-secondary',
      title: 'Availability: Online',
      data: { 'toggle': 'tooltip' }
    )
    data << content_tag(
      :div,
      'Online access is not currently available.',
      class: 'library-location'
    )
  end

  def online_holding_block(links)
    data = content_tag(
      :span,
      'Online',
      class: 'availability-icon badge badge-primary',
      title: 'Electronic access',
      data: { 'toggle': 'tooltip' }
    )
    data << links.shift
  end

  def onsite_access_span
    content_tag(
      :span,
      'On-site access',
      class: 'availability-icon badge badge-success',
      title: 'Availability: On-site by request',
      data: { 'toggle': 'tooltip' }
    )
  end

  def request_only_span
    content_tag(
      :span,
      '',
      class: 'icon-warning icon-request-reading-room',
      title: 'Items at this location must be requested',
      data: { 'toggle': 'tooltip' },
      'aria-hidden': 'true'
    )
  end

  def dspace_or_numismatics_holding_block(location)
    data = onsite_access_span
    data << request_only_span if aeon_location?(location)
    data
  end

  def scsb_item_block(holding)
    scsb_supervised_items?(holding) ? scsb_supervised_item : scsb_unsupervised_item(holding)
  end

  def scsb_supervised_item
    onsite_access_span + request_only_span
  end

  def scsb_unsupervised_item(holding)
    content_tag(
      :span,
      '',
      class: 'availability-icon badge',
      title: '',
      data: {
        'scsb-availability': 'true',
        'toggle': 'tooltip',
        'scsb-barcode': holding['items'].first['barcode'].to_s
      }
    )
  end

  def dspace_not_defined_block(location)
    data = content_tag(
      :span,
      'Loading...',
      class: 'availability-icon badge badge-secondary'
    )
    data << request_only_span if aeon_location?(location)
    data
  end

  def under_embargo_block
    content_tag(
      :span,
      'Unavailable',
      class: 'availability-icon badge badge-danger',
      title: 'Availability: Material under embargo',
      data: { 'toggle': 'tooltip' }
    )
  end

  def library_location_div(holding, document, id)
    content_tag(
      :div,
      search_location_display(holding, document),
      class: 'library-location',
      data: {
        location: true,
        record_id: document['id'],
        holding_id: id
      }
    )
  end

  def holding_status_li(accumulator, document, check_availability, id, holding)
    location = holding_location(holding)
    content_tag(
      :li,
      accumulator,
      class: 'holding-status',
      data: {
        availability_record: check_availability,
        record_id: document['id'],
        holding_id: id,
        temp_location_code: holding['temp_location_code'],
        aeon: aeon_location?(location),
        bound_with: document.bound_with?
      }.compact
    )
  end

  def cdl_placeholder
    content_tag(
      :span,
      '',
      class: 'badge badge-primary',
      data: { 'availability-cdl': true }
    )
  end

  def view_record_for_full_avail_li(document)
    content_tag(
      :li,
      link_to(
        'View Record for Full Availability',
        solr_document_path(document['id']),
        class: 'availability-icon badge badge-secondary more-info',
        title: 'Click on the record for full availability info',
        data: { 'toggle': 'tooltip' }
      )
    )
  end

  def view_record_for_full_avail_li_two(document)
    content_tag(
      :li,
      link_to(
        '',
        solr_document_path(document['id']),
        class: 'availability-icon more-info',
        title: 'Click on the record for full availability info',
        data: { 'toggle': 'tooltip' }
      ),
      class: 'empty',
      data: { record_id: document['id'] }
    )
  end

  def additional_holdings_span
    content_tag(
      :span,
      "View record for information on additional holdings",
      "style": "font-size: small; font-style: italic;"
    )
  end
end
# rubocop:enable Metrics/ModuleLength

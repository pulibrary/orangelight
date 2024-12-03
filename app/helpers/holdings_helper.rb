# frozen_string_literal: false

# rubocop:disable Metrics/ModuleLength
module HoldingsHelper
  # Generate the markup block for individual search result items containing holding information
  # @param document [SolrDocument] the Solr Document retrieved in the search result set
  # @return [String] the markup

  def holding_block_search(document)
    block = ''.html_safe
    holdings_hash = document.holdings_all_display
    @scsb_multiple = false

    holdings_hash.first(2).each do |id, holding|
      block << first_two_holdings_block(document, id, holding)
    end

    block << controller.view_context.render(Holdings::OnlineHoldingsComponent.new(document:))

    if @scsb_multiple == true || holdings_hash.length > 2
      block << view_record_for_full_avail_li(document)
    elsif !holdings_hash.empty?
      block << view_record_for_full_avail_li_two(document)
    end

    if block.empty?
      content_tag(:div, t('blacklight.holdings.search_missing'))
    else
      content_tag(:ul, block)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # Currently having trouble breaking up this method further due to the "check_availability" variable
  def first_two_holdings_block(document, id, holding)
    location = holding_location(holding)
    check_availability = render_availability?
    accumulator = ''.html_safe
    if holding['library'] == 'Online'
      rendered_online_holdings_block = controller.view_context.render(Holdings::OnlineHoldingsComponent.new(document:))
      return rendered_online_holdings_block if rendered_online_holdings_block.present?

      check_availability = render_availability?
      accumulator << empty_link_online_holding_block

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

  def empty_link_online_holding_block
    data = content_tag(
      :span,
      'Link Missing',
      class: 'availability-icon badge bg-secondary'
    )
    data << content_tag(
      :div,
      'Online access is not currently available.',
      class: 'library-location'
    )
  end

  def onsite_access_span
    content_tag(
      :span,
      'On-site access',
      class: 'availability-icon badge bg-success'
    )
  end

  def dspace_or_numismatics_holding_block(_location)
    onsite_access_span
  end

  def scsb_item_block(holding)
    scsb_supervised_items?(holding) ? scsb_supervised_item : scsb_unsupervised_item(holding)
  end

  def scsb_supervised_item
    onsite_access_span
  end

  def scsb_unsupervised_item(holding)
    content_tag(
      :span,
      '',
      class: 'availability-icon badge',
      data: {
        'scsb-availability': 'true',
        'scsb-barcode': holding['items'].first['barcode'].to_s
      }
    )
  end

  def dspace_not_defined_block(_location)
    content_tag(
      :span,
      'Loading...',
      class: 'availability-icon badge bg-secondary'
    )
  end

  def under_embargo_block
    content_tag(
      :span,
      'Unavailable',
      class: 'availability-icon badge bg-danger'
    )
  end

  def library_location_div(holding, document, id)
    content_tag(
      :div,
      search_location_display(holding),
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

  def view_record_for_full_avail_li(document)
    content_tag(
      :li,
      link_to(
        'View Record for Full Availability',
        solr_document_path(document['id']),
        class: 'availability-icon badge bg-secondary more-info'
      )
    )
  end

  def view_record_for_full_avail_li_two(document)
    content_tag(
      :li,
      link_to(
        '',
        solr_document_path(document['id']),
        class: 'availability-icon more-info'
      ),
      class: 'empty',
      data: { record_id: document['id'] }
    )
  end
end
# rubocop:enable Metrics/ModuleLength

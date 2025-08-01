# frozen_string_literal: false

# rubocop:disable Metrics/ModuleLength
module HoldingsHelper
  # Generate the markup block for individual search result items containing holding information
  # @param document [SolrDocument] the Solr Document retrieved in the search result set
  # @return [String] the markup

  # rubocop:disable Metrics/MethodLength
  def holding_block_search(document)
    block = ''.html_safe
    block_extra = ''.html_safe
    holdings_hash = document.holdings_all_display.sort { |a, b| sort_holdings(a, b) }
    @scsb_multiple = false
    if holdings_hash.count <= 4
      holdings_hash.each do |id, holding|
        block << holdings_block(document, id, holding)
      end
    elsif holdings_hash.count > 4
      holdings_array = holdings_hash.to_a
      holdings_array_first_three = holdings_array.first(3)
      holdings_array.count
      holdings_remaining = holdings_array.count - 3

      holdings_array_first_three.each do |id, holding|
        block << holdings_block(document, id, holding)
      end
      block_extra << content_tag(:a, href: "/catalog/#{document['id']}") do
        content_tag(:"lux-card", class: 'show-more-holdings') do
          content_tag(:span, "See #{holdings_remaining} more locations", class: 'lux-text-style blue')
        end
      end

      block << block_extra

    end

    if block.empty?
      ''
    else
      content_tag(:div, block, class: "holdings-card")
    end
  end
  # rubocop:enable Metrics/MethodLength

  def online_content_block(document)
    controller.view_context.render(Holdings::OnlineHoldingsComponent.new(document:))
  end

  # rubocop:disable Metrics/MethodLength
  # Currently having trouble breaking up this method further due to the "check_availability" variable
  def holdings_block(document, id, holding)
    location = holding_location(holding)
    check_availability = render_availability?
    accumulator = ''.html_safe
    if holding['library'] == 'Online'
      rendered_online_holdings_block = controller.view_context.render(Holdings::OnlineHoldingsComponent.new(document:))
      return rendered_online_holdings_block if rendered_online_holdings_block.present?

      check_availability = render_availability?
      accumulator << empty_link_online_holding_block

    else
      accumulator << library_location_div(holding, document, id)
      if holding['dspace'] || holding['location_code'] == 'rare$num'
        check_availability = false
        accumulator << dspace_or_numismatics_holding_block
      elsif /^scsb.+/.match? location[:code]
        check_availability = false
        unless holding['items'].nil?
          @scsb_multiple = true unless holding['items'].one?
          accumulator << scsb_item_block(holding)
        end
      elsif holding['dspace'].nil?
        accumulator << dspace_not_defined_block(location)
      else
        check_availability = false
        accumulator << under_embargo_block
      end
    end
    holding_status_li(accumulator, document, check_availability, id, holding)
  end
  # rubocop:enable Metrics/MethodLength

  def empty_link_online_holding_block
    data = content_tag(
      :span,
      'Link Missing',
      class: 'lux-text-style gray strong'
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
      class: 'lux-text-style green strong'
    )
  end

  def available_access_span
    content_tag(
      :span,
      'Available',
      class: 'lux-text-style green strong'
    )
  end

  def dspace_or_numismatics_holding_block
    available_access_span
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
      class: 'lux-text-style',
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
      class: 'lux-text-style gray strong'
    )
  end

  def under_embargo_block
    content_tag(
      :span,
      'Request',
      class: 'lux-text-style gray strong'
    )
  end

  def library_location_div(holding, document, id)
    content_tag(
      :div,
      ApplicationController.new.view_context.render(Holdings::SearchLocationComponent.new(holding)),
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
    content_tag(:a, href: "/catalog/#{document['id']}") do
      content_tag(
        :'lux-card',
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
  end

  private

    # rubocop:disable Naming/MethodParameterName
    # rubocop:disable Lint/DuplicateBranch
    # :reek:DuplicateMethodCall
    # :reek:TooManyStatements
    # :reek:UncommunicativeParameterName
    # :reek:UtilityFunction
    def sort_holdings(a, b)
      # First, check if one of the items is Firestone.  If so, it should come first
      if a.second['location_code'].starts_with?('firestone') && !b.second['location_code'].starts_with?('firestone')
        -1
      elsif b.second['location_code'].starts_with?('firestone') && !a.second['location_code'].starts_with?('firestone')
        1
      # Next, check if one of the items is Recap.  If so, it should come last
      elsif a.second['location_code'].starts_with?('recap') && !b.second['location_code'].starts_with?('recap')
        1
      elsif b.second['location_code'].starts_with?('recap') && !a.second['location_code'].starts_with?('recap')
        -1
      # Next, check if one of the items is Annex.  If so, it should come last (but still before recap, which was handled previously)
      elsif a.second['location_code'].starts_with?('annex') && !b.second['location_code'].starts_with?('annex')
        1
      elsif b.second['location_code'].starts_with?('annex') && !a.second['location_code'].starts_with?('annex')
        -1
      else
        a.second['location_code'] <=> b.second['location_code']
      end
    end
  # rubocop:enable Naming/MethodParameterName
  # rubocop:enable Lint/DuplicateBranch
end
# rubocop:enable Metrics/ModuleLength

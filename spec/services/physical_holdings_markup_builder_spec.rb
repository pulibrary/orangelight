# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PhysicalHoldingsMarkupBuilder do
  it 'opens the first holding group by default' do
    adapter = instance_double HoldingRequestsAdapter,
                              grouped_physical_holdings: [
                                Requests::HoldingGroup.new(group_name: 'Marquand Library - Remote Storage: Marquand Use Only', holdings: []),
                                Requests::HoldingGroup.new(group_name: 'ReCAP - Remote Storage', holdings: [])
                              ]

    rendered = Nokogiri::HTML::DocumentFragment.parse(described_class.new(adapter).build)
    holding_groups = rendered.css('details')

    expect(holding_groups[0].attribute('open')).to be_present
    expect(holding_groups[1].attribute('open')).not_to be_present
  end

  it 'opens the group specified in the open_holdings param' do
    adapter = instance_double HoldingRequestsAdapter,
                              grouped_physical_holdings: [
                                Requests::HoldingGroup.new(group_name: 'Marquand Library - Remote Storage: Marquand Use Only', holdings: []),
                                Requests::HoldingGroup.new(group_name: 'ReCAP - Remote Storage', holdings: [])
                              ]

    params = ActionController::Parameters.new(open_holdings: 'ReCAP - Remote Storage')

    rendered = Nokogiri::HTML::DocumentFragment.parse(described_class.new(adapter, params).build)
    holding_groups = rendered.css('details')

    expect(holding_groups[0].attribute('open')).to be_present
    expect(holding_groups[1].attribute('open')).to be_present
  end
end

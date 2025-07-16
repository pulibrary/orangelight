# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Holdings::HoldingAvailabilityComponent, type: :component do
  it "renders a td" do
    holding_availability = described_class.new(
      '994831543506421', # doc_id
      '22549882290006421', # holding_id
      {}, # location_rules
      nil # temp_location_code
    )
    expect(render_inline(holding_availability).css('td').length).to eq 1
    expect(render_inline(holding_availability).css('td').attribute('class').value).to eq 'holding-status'
    expect(render_inline(holding_availability).css('td').attribute('data-availability-record').value).to eq 'true'
    expect(render_inline(holding_availability).css('td').attribute('data-record-id').value).to eq '994831543506421'
    expect(render_inline(holding_availability).css('td').attribute('data-holding-id').value).to eq '22549882290006421'
  end

  it "includes an availability icon" do
    holding_availability = described_class.new(
      '994831543506421', # doc_id
      '22549882290006421', # holding_id
      {}, # location_rules
      nil # temp_location_code
    )
    expect(render_inline(holding_availability).css('td span').attribute('class').value).to include 'availability-icon'
  end
end

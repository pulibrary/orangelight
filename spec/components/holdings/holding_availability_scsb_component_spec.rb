# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::HoldingAvailabilityScsbComponent, type: :component do
  let(:holding_json) { '{"location_code":"scsbnypl","location":"Remote Storage","library":"ReCAP","call_number":"*DT (Nea hestia) v. 89, no. 1044 - 1055 (1971)","call_number_browse":"*DT (Nea hestia) v. 89, no. 1044 - 1055 (1971)","items":[{"holding_id":"7854805","description":"v. 1668 - 1679 (Jan. - Jun. 1997)","id":"12848611","status_at_load":"Available","barcode":"33433097876571","copy_number":"1","use_statement":"In Library Use","storage_location":"RECAP","cgd":"Open","collection_code":"NA"}]}' }

  it "renders a td" do
    holding_location = described_class.new(
      JSON.parse(holding_json), # holding
      'SCSB-14168459', # doc_id
      '7854805' # holding_id
    )
    expect(render_inline(holding_location).css('td').length).to eq 1
    expect(render_inline(holding_location).css('td').attribute('class').value).to eq 'holding-status'
    expect(render_inline(holding_location).css('td').attribute('data-availability-record').value).to eq 'true'
    expect(render_inline(holding_location).css('td').attribute('data-record-id').value).to eq 'SCSB-14168459'
    expect(render_inline(holding_location).css('td').attribute('data-holding-id').value).to eq '7854805'
    expect(render_inline(holding_location).css('td').attribute('data-scsb-barcode').value).to eq '33433097876571'
    expect(render_inline(holding_location).css('td').attribute('data-aeon').value).to eq 'false'
  end

  it "includes an availability icon" do
    holding_location = described_class.new(
      JSON.parse(holding_json), # holding
      'SCSB-14168459', # doc_id
      '7854805' # holding_id
    )
    expect(render_inline(holding_location).css('td span').attribute('class').value).to include 'availability-icon'
    expect(render_inline(holding_location).css('td span').attribute('class').value).to include 'lux-text-style'
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Holdings::LibmapButtonComponent, type: :component do
  let :holding do
    {
      call_number: 'D1 .H57865',
      library: 'Firestone Library',
      location: 'Firestone Stacks'
    }.with_indifferent_access
  end
  let :oversize_holding do
    {
      call_number: 'D1 .H57865q',
      library: 'Firestone Library',
      location: 'Firestone Stacks',
      sub_location: ['Oversize']
    }.with_indifferent_access
  end
  let :rendered do
    render_inline described_class.new(adapter, holding)
  end
  let :rendered_oversize do
    render_inline described_class.new(adapter, oversize_holding)
  end
  let(:adapter) { instance_double(HoldingRequestsAdapter) }
  let(:document) { SolrDocument.new({ id: '123456', title_display: 'A Title' }) }
  before do
    allow(adapter).to receive(:document).and_return(document)
  end

  it 'is an empty dev in a table cell' do
    expect(rendered.css('td').length).to eq 1
    expect(rendered.css('div').length).to eq 1
    expect(rendered.css('div').text.strip).to eq ''
  end

  it 'puts the record title in a data-title attribute' do
    expect(rendered.to_s).to include 'data-title="A Title"'
  end
  it 'puts the holding call number in a data-callnumber attribute' do
    expect(rendered.to_s).to include 'data-callnumber="D1 .H57865"'
  end

  it 'puts the library a record is located in a data-library attribute' do
    expect(rendered.to_s).to include 'data-location="Firestone Library"'
  end

  it 'puts the holding location name in a data-collection attribute' do
    expect(rendered.to_s).to include 'data-collection="Firestone Stacks"'
  end

  it 'puts the holding location name with the Oversize collection prefix in a data-collection attribute' do
    expect(rendered_oversize.to_s).to include 'data-collection="Oversize Firestone Stacks"'
  end
end

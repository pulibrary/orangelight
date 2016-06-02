require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#holding_block helpers' do
    let(:holding_id) { '3580281' }
    let(:library) { 'Rare Books and Special Collections' }
    let(:location) { 'Rare Books and Special Collections - Reference Collection in Dulles Reading Room' }
    let(:call_number) { 'PS3539.A74Z93 2000' }
    let(:search_result) { helper.holding_block_search(document) }
    let(:search_result_thesis) { helper.holding_block_search(document_thesis) }
    let(:empty_search_result) { helper.holding_block_search(document_no_holdings) }
    let(:show_result) { helper.holding_request_block(document) }
    let(:show_result_journal) { helper.holding_request_block(document_journal) }
    let(:show_result_thesis) { helper.holding_request_block(document_thesis) }
    let(:holding_block_json) do
      {
        holding_id => {
          location: location,
          library: library,
          location_code: 'exb',
          call_number: call_number,
          call_number_browse: call_number
        },
        '3595800' => {
          location: 'Online - Online Resources',
          library: 'Online',
          location_code: 'elf3'
        },
        '3595801' => {
          location: 'ReCAP',
          library: 'ReCAP',
          location_code: 'rcppa',
          call_number: 'PS3539.A74Z93 2000'
        },
        '3668455' => {
          location: 'Firestone Library',
          library: 'Firestone Library',
          location_code: 'f',
          call_number: 'PS3539.A74Z93 2000'
        },
        '4362737' => {
          location: 'Firestone Library',
          library: 'Firestone Library',
          location_code: 'f',
          call_number: 'PS3539.A74Z93 2000'
        }
      }.to_json.to_s
    end
    let(:holdings_thesis_mudd) do
      {
        'thesis' => {
          location: 'Mudd Manuscript Library',
          library: 'Mudd Manuscript Library',
          location_code: 'mudd',
          dspace: true
        }
      }.to_json.to_s
    end

    let(:document) do
      {
        id: '1',
        format: ['Book'],
        holdings_1display: holding_block_json
      }.with_indifferent_access
    end

    let(:document_no_holdings) do
      {
        id: '2'
      }.with_indifferent_access
    end

    let(:document_journal) do
      {
        id: '3',
        format: ['Journal'],
        holdings_1display: holding_block_json
      }.with_indifferent_access
    end

    let(:document_thesis) do
      {
        id: '4',
        format: ['Senior Thesis'],
        holdings_1display: holdings_thesis_mudd
      }.with_indifferent_access
    end

    let(:field_config) do
      {
        field: :holdings_1display,
        document: document
      }.with_indifferent_access
    end
    context 'search results when there are more than two call numbers' do
      it 'displays View Record for Availability' do
        expect(search_result).to include 'View Record for Full Availability'
      end
      it 'has an availability icon' do
        expect(search_result).to have_selector ".availability-icon[title='Click on the record for full availability info']"
      end
    end
    context '#holding_block_search' do
      it 'returns a good string' do
        expect(search_result).to include call_number
        expect(search_result).to include library
      end
      it 'tags the record id' do
        expect(search_result).to have_selector "*[data-availability-record][data-record-id='1']"
      end
      it 'tags the holding record id' do
        expect(search_result).to have_selector "*[data-availability-record][data-holding-id='#{holding_id}']"
      end
      it 'wraps the record' do
        expect(search_result).to have_selector '*[data-availability-record]'
      end
      it 'has an availability icon' do
        expect(search_result).to have_selector '.availability-icon'
      end
      it 'link missing label appears when 856s is missing from elf location' do
        expect(search_result).to include 'Link Missing'
      end
      it 'On-site access availability when dspace set to true' do
        expect(search_result_thesis).to include 'On-site access'
      end
      it 'indicates when there are no holdings for a record' do
        expect(empty_search_result).to include t('blacklight.holdings.search_missing')
      end
    end
    context '#holding_block record show - physical holdings' do
      it 'returns a string with call number and location display values' do
        expect(show_result.last).to include call_number
        expect(show_result.last).to include library
      end
      it 'link to call number browse' do
        expect(show_result.last).to have_link(t('blacklight.holdings.browse'), href: "/browse/call_numbers?q=#{call_number}")
      end
      it 'tooltip for the call number browse' do
        expect(show_result.last).to have_selector "*[title='Browse: #{call_number}']"
      end
      it 'tags the holding record id' do
        expect(show_result.last).to have_selector "*[data-holding-id='#{holding_id}']"
      end
      it 'On-site access availability when dspace set to true' do
        expect(show_result_thesis.last).to include 'On-site access'
      end
      it 'includes a div to place current issues when journal format' do
        expect(show_result_journal.last).to have_selector '*[data-journal]'
      end
      it 'excludes a div to place current issues when not journal format' do
        expect(show_result.last).not_to have_selector '*[data-journal]'
      end
    end
    context '#holding_block record show - online holdings' do
      it 'link missing label appears when 856s is missing from elf location' do
        expect(show_result.first).to include 'Link Missing'
      end
    end
  end
end

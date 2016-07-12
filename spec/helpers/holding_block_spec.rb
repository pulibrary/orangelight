require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#pageable?' do
    let(:pageable_holding) { helper.pageable?(holding_in_range) }
    let(:not_pageable_holding) { helper.pageable?(holding_out_of_range) }
    let(:not_lc_call_num) { helper.pageable?(non_lc_call_num) }
    let(:holding_in_range) do
      {
        'location' => 'Firestone Library - Near East Collections',
        'library' => 'Firestone Library',
        'location_code' => 'nec',
        'call_number' => 'PZ6611.T3F545 1987',
        'call_number_browse' => 'PZ6611.T3F545 1987'
      }
    end

    let(:holding_out_of_range) do
      {
        'location' => 'Firestone Library - Near East Collections',
        'library' => 'Firestone Library',
        'location_code' => 'nec',
        'call_number' => 'Z6611.T3F545 1987',
        'call_number_browse' => 'Z6611.T3F545 1987'
      }
    end

    let(:non_lc_call_num) do
      {
        'location' => 'Firestone Library - Near East Collections',
        'library' => 'Firestone Library',
        'location_code' => 'nec',
        'call_number' => '33334.53535',
        'call_number_browse' => '33334.53535'
      }
    end

    context 'When Holding is in pageable range' do
      it 'returns true when the call number is in range' do
        expect(pageable_holding).to be_truthy
      end

      it 'returns nil when the call number is out of range' do
        expect(not_pageable_holding).to be_nil
      end

      it 'returns nil when the call number is not an LC number' do
        expect(not_lc_call_num).to be_nil
      end
    end
  end

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
    let(:show_result_marcit) { helper.urlify(electronic_access_marcit) }
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

    let(:marcit_url) { 'http://getit.princeton.edu/resolve?url%5Fver=Z39.88-2004&ctx%5Fver=Z39.88-2004&ctx%5Fenc=info:ofi/enc:UTF-8&rfr%5Fid=info:sid/sfxit.com:opac%5F856&url%5Fctx%5Ffmt=info:ofi/fmt:kev:mtx:ctx&sfx.ignore%5Fdate%5Fthreshold=1&rft.object%5Fid=954925427238&svc%5Fval%5Ffmt=info:ofi/fmt:kev:mtx:sch%5Fsvc&' }
    let(:marcit_ctx) { 'url%5Fver=Z39.88-2004&ctx%5Fver=Z39.88-2004&ctx%5Fenc=info:ofi/enc:UTF-8&rfr%5Fid=info:sid/sfxit.com:opac%5F856&url%5Fctx%5Ffmt=info:ofi/fmt:kev:mtx:ctx&sfx.ignore%5Fdate%5Fthreshold=1&rft.object%5Fid=954925427238&svc%5Fval%5Ffmt=info:ofi/fmt:kev:mtx:sch%5Fsvc&' }
    let(:electronic_access_marcit) do
      {
        marcit_url => ['getit.princeton.edu', 'View Princeton online holdings']
      }.to_json
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
        expect(show_result.last).to have_link(t('blacklight.holdings.browse'), href: "/browse/call_numbers?q=#{CGI.escape call_number}")
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
    context '#urlify a marcit record' do
      it 'is marked as full text record' do
        expect(show_result_marcit).to have_selector "*[data-umlaut-fulltext='true']"
      end

      it 'has a marcit context object' do
        expect(show_result_marcit).to include 'data-url-marcit'
        expect(show_result_marcit).to have_selector "*[data-url-marcit='#{marcit_ctx}']"
      end
    end
  end
end

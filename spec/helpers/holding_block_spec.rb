# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#holding_block helpers' do
    let(:holding_id) { '3580281' }
    let(:library) { 'Rare Books and Special Collections' }
    let(:location) { 'Rare Books and Special Collections - Reference Collection in Dulles Reading Room' }
    let(:call_number) { 'PS3539.A74Z93 2000' }
    let(:search_result) { helper.holding_block_search(SolrDocument.new(document)) }
    let(:search_result_thesis) { helper.holding_block_search(SolrDocument.new(document_thesis)) }
    let(:empty_search_result) { helper.holding_block_search(SolrDocument.new(document_no_holdings)) }

    let(:show_result) { helper.holding_request_block(SolrDocument.new(document)) }
    let(:show_result_journal) { helper.holding_request_block(SolrDocument.new(document_journal)) }
    let(:show_result_thesis) { helper.holding_request_block(SolrDocument.new(document_thesis)) }
    let(:show_result_thesis_no_request) { helper.holding_request_block(SolrDocument.new(document_thesis_no_request_access)) }
    let(:show_result_thesis_embargoed) { helper.holding_request_block(SolrDocument.new(document_thesis_embargoed)) }

    let(:show_result_umlaut_w_full_text) { helper.umlaut_services }
    let(:not_umlaut_full_text_eligible) { SolrDocument.new(document_no_umlaut) }
    let(:umlaut_full_text_eligible) { SolrDocument.new(document) }
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

    let(:holdings_thesis_mudd_embargoed) do
      {
        'thesis' => {
          location: 'Mudd Manuscript Library',
          library: 'Mudd Manuscript Library',
          location_code: 'mudd',
          dspace: false
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
    let(:document_no_umlaut) do
      {
        id: '5',
        format: ['Video'],
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
        holdings_1display: holdings_thesis_mudd,
        pub_date_start_sort: 2008
      }.with_indifferent_access
    end

    let(:document_thesis_no_request_access) do
      {
        id: '4',
        format: ['Senior Thesis'],
        holdings_1display: holdings_thesis_mudd,
        pub_date_start_sort: 2013
      }.with_indifferent_access
    end

    let(:document_thesis_embargoed) do
      {
        id: '4',
        format: ['Senior Thesis'],
        holdings_1display: holdings_thesis_mudd_embargoed,
        pub_date_start_sort: 2021
      }.with_indifferent_access
    end

    let(:document_with_standard_numbers_w_online) do
      {
        id: '5',
        oclc_s: ['123456'],
        isbn_s: ['9781317536571'],
        electronic_access_1display: '856 link values'
      }.with_indifferent_access
    end

    let(:document_with_standard_numbers_no_online) do
      {
        id: '5',
        oclc_s: ['123456']
      }.with_indifferent_access
    end

    let(:document_with_no_standard_numbers_no_online) do
      {
        id: '5',
        title_display: 'A Book'
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
    let(:open_access_url) { 'http://hdl.handle.net/1802/27831' }
    let(:open_access_electronic_display) do
      {
        open_access_url => ['Open access']
      }.to_json
    end
    let(:electronic_access_url) { 'http://hdl.handle.net/1802/27831' }
    let(:electronic_display) do
      {
        electronic_access_url => ['I am a label']
      }.to_json
    end

    context 'search results when there are more than two call numbers' do
      before { stub_holding_locations }

      it 'displays View Record for Availability' do
        expect(search_result).to include 'View Record for Full Availability'
      end
      it 'has an availability icon' do
        expect(search_result).to have_selector ".availability-icon[title='Click on the record for full availability info']"
      end
    end
    context '#holding_block_search' do
      before { stub_holding_locations }

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
    context '#holding_block_search with a missing location code' do
      let(:holding_block_json) do
        {
          holding_id => {
            location: location,
            library: library,
            call_number: call_number,
            call_number_browse: call_number
          }
        }.to_json.to_s
      end

      before { stub_holding_locations }

      it 'includes the item in the result without an error' do
        expect(search_result).to include call_number
      end
    end

    context '#holding_block_search with links only' do
      let(:document) do
        {
          id: '1',
          format: ['Book'],
          electronic_access_1display: '{"https://purl.fdlp.gov/GPO/LPS40377":["purl.fdlp.gov"]}'
        }.with_indifferent_access
      end

      before { stub_holding_locations }

      it 'includes the online badge since there is an electronic access link' do
        # In this case we just look for the Online badge (the link is not rendered.)
        holdings_block = helper.holding_block_search(SolrDocument.new(document))
        expect(holdings_block).to include ">Online</span"
      end
    end

    context '#holding_block record show - physical holding thesis reading room request' do
      before { stub_holding_locations }

      it 'displays a Reading Room Request button' do
        expect(show_result_thesis.last).to include 'Reading Room Request'
      end
      it 'displays a Reading Room Request Tooltip' do
        expect(show_result_thesis.last).to have_selector "*[title='Request to view in Reading Room']"
      end
      it 'displays a reading room request as Always requestable' do
        expect(show_result_thesis.last).to have_selector '.service-always-requestable'
      end
    end

    context '#holding_block record show - thesis after 2012' do
      it 'does not display a request button for theses created after 2012' do
        stub_holding_locations
        expect(show_result_thesis_no_request.last).not_to have_selector '.service-always-requestable'
      end
    end

    context '#holding_block record show - thesis embargoed' do
      before { stub_holding_locations }
      it 'does not display a request button for theses with dspace:false' do
        expect(show_result_thesis_embargoed.last).not_to have_selector '.service-always-requestable'
        expect(show_result_thesis_embargoed.last).to have_selector '.service-conditional'
      end
      it 'does not display a Reading Room Request button' do
        expect(show_result_thesis_embargoed.last).to include 'data-requestable="false"'
      end
    end

    context '#holding_block record show - online holdings' do
      it 'link missing label appears when 856s is missing from elf location' do
        stub_holding_locations
        expect(show_result.first).to include 'Link Missing'
      end
    end

    context '#umlaut_format_eligible? formats' do
      it 'is false when it is not umlaut format' do
        expect(not_umlaut_full_text_eligible.umlaut_fulltext_eligible?).to be false
      end
      it 'is true when it is an umlaut format' do
        expect(umlaut_full_text_eligible.umlaut_fulltext_eligible?).to be true
      end
    end

    context '#holding_block record show - physical holdings' do
      let(:search_result) { helper.holding_block_search(document) }
      let(:call_number) { 'CD- 2018-11-11' }
      let(:library) { 'Mendel Music Library' }
      let(:document) do
        {
          id: '99112325153506421',
          format: ['Audio'],
          holdings_1display: holding_block_json
        }.with_indifferent_access
      end
      let(:holding_block_json) do
        {
          '22270490550006421' => {
            location: 'Mendel Music Library: Reserve',
            library: library,
            location_code: 'mendel$res',
            call_number: call_number,
            call_number_browse: call_number
          },
          '22270490570006421' => {
            location: 'Remote Storage (ReCAP)',
            library: library,
            location_code: 'mendel$pk',
            call_number: 'CD- 2018-11-11 MASTER',
            call_number_browse: 'CD- 2018-11-11 MASTER'
          },
          '22270490580006421' => {
            location: '',
            library: 'Very Special Library',
            location_code: 'xspecial&nil',
            call_number: 'special',
            call_number_browse: 'special'
          }
        }.to_json.to_s
      end

      before { stub_holding_locations }

      it 'returns a string with call number and location display values' do
        expect(show_result.last).to include call_number
        expect(show_result.last).to include library
        expect(show_result.last).to include 'Remote Storage (ReCAP)'
        expect(show_result.last).to include 'Mendel Music Library: Reserve'
      end

      it 'link to call number browse' do
        expect(show_result.last).to have_link(t('blacklight.holdings.browse'), href: "/browse/call_numbers?q=#{CGI.escape call_number}")
      end
      it 'tooltip for the call number browse' do
        expect(show_result.last).to have_selector "*[title='Browse: #{call_number}']"
      end
      it 'tags the holding record id' do
        expect(show_result.last).to have_selector "*[data-holding-id='22270490550006421']"
      end
      it 'On-site access availability when dspace set to true' do
        expect(show_result_thesis.last).to include 'On-site access'
      end
      it 'On-site access availability when dspace set to false' do
        expect(show_result_thesis_embargoed.last).to include 'Unavailable'
      end
      it 'includes a div to place current issues when journal format' do
        expect(show_result_journal.last).to have_selector '*[data-journal]'
      end
      it 'excludes a div to place current issues when not journal format' do
        expect(show_result.last).not_to have_selector '*[data-journal]'
      end
    end
  end
end

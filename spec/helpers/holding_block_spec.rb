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
        expect(search_result).to include 'View record for information on additional holdings'
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

    context '#holding_block_search and the find it pin icon' do
      let(:document_with_find_it_link) do
        {
          id: '1',
          format: ['Book'],
          holdings_1display: {
            "22123123123" => {
              location_code: "firestone$stacks",
              call_number: "FIRE-123",
              call_number_browse: "FIRE-123",
              location: "Stacks",
              library: "Firestone"
            }
          }.to_json.to_s
        }.with_indifferent_access
      end

      let(:document_without_find_it_link) do
        {
          id: '1',
          format: ['Book'],
          holdings_1display: {
            "22789789789" => {
              location_code: "plasma$stacks",
              call_number: "PLASMA-123",
              call_number_browse: "PLASMA-123",
              location: "Stacks",
              library: "Plasma"
            }
          }.to_json.to_s
        }.with_indifferent_access
      end

      before { stub_holding_locations }

      # For most locations a map icon is displayed to help patrons if they want to fetch the item.
      it 'includes the find it icon' do
        search_result = helper.holding_block_search(SolrDocument.new(document_with_find_it_link))
        expect(search_result).to include "fa-map-marker"
      end

      # For certain locations a map icon is not displayed if the location is not accessible by patrons.
      it 'does not include the find it icon' do
        search_result = helper.holding_block_search(SolrDocument.new(document_without_find_it_link))
        expect(search_result).not_to include "fa-map-marker"
      end
    end

    context '#holding_block_search with links only' do
      let(:document) do
        {
          id: '1',
          format: ['Book'],
          electronic_access_1display: '{"https://library.princeton.edu/resource/28076":["library.princeton.edu"]}'
        }.with_indifferent_access
      end

      before { stub_holding_locations }

      it 'includes the online badge and link since there is an electronic access link' do
        holdings_block = helper.holding_block_search(SolrDocument.new(document))
        expect(holdings_block).to include ">Online</span"
        expect(holdings_block).to include "library.princeton.edu"
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

    context '#holding_block record show - special collections non-requestable locations' do
      before { stub_alma_holding_locations }
      describe 'special collection location rare$xmr' do
        let(:show_result_sp_rare_xmr) { helper.holding_request_block(SolrDocument.new(document_sc_location_on_site_access)) }
        let(:document_sc_location_on_site_access) do
          {
            id: '99125501031906421',
            format: ['Manuscript'],
            holdings_1display: {
              "22943439080006421" => {
                location_code: "rare$xmr",
                location: "Remote Storage (ReCAP): Manuscripts. Special Collections Use Only",
                library: "Special Collections",
                call_number: "C1695",
                call_number_browse: "C1695"
              }
            }.to_json.to_s
          }.with_indifferent_access
        end

        it 'does not display a request button' do
          expect(show_result_sp_rare_xmr.last).not_to have_selector '.service-always-requestable'
          expect(show_result_sp_rare_xmr.last).to have_selector '.service-conditional'
        end
        it 'does not display a Reading Room Request button' do
          expect(show_result_sp_rare_xmr.last).to include 'data-requestable="false"'
        end
      end
      describe 'special collection location rare$scahsvc' do
        let(:show_result_sp_rare_scahsvc) { helper.holding_request_block(SolrDocument.new(document_sc_location_on_site_access_rare_scahsvc)) }
        let(:document_sc_location_on_site_access_rare_scahsvc) do
          {
            id: '99125501031906421',
            format: ['Manuscript'],
            holdings_1display: {
              "22943439180006421" => {
                location_code: "rare$scahsvc",
                location: "Cotsen Children's Library Archival. Special Collections Use Only",
                library: "Special Collections",
                call_number: "C1694",
                call_number_browse: "C1694"
              }
            }.to_json.to_s
          }.with_indifferent_access
        end

        it 'does not display a request button' do
          expect(show_result_sp_rare_scahsvc.last).not_to have_selector '.service-always-requestable'
          expect(show_result_sp_rare_scahsvc.last).to have_selector '.service-conditional'
        end
        it 'does not display a Reading Room Request button' do
          expect(show_result_sp_rare_scahsvc.last).to include 'data-requestable="false"'
        end
      end
    end

    context '#holding_block record show - online holdings' do
      it 'link missing label appears when 856s is missing from elf location' do
        stub_holding_locations
        expect(show_result.first).to include 'Link Missing'
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
        expect(show_result.last).to include 'Mendel Music Library - Reserve'
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

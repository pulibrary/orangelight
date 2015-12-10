require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#holding_block helpers" do
    let(:holding_id) { '3580281' }
    let(:library) { 'Rare Books and Special Collections' }
    let(:location) { 'Rare Books and Special Collections - Reference Collection in Dulles Reading Room' }
    let(:call_number) { 'PS3539.A74Z93 2000' }
    let(:search_result) { helper.holding_block_search(field_config) }
    let(:show_result) { helper.holding_request_block(holding_block_json, 1) }
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
          location_code: 'elf3',
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

    let(:field_config) do
      {
        field: :holdings_1display,
        document: {
          id: '1',
          holdings_1display: holding_block_json
        }
      }.with_indifferent_access
    end
    context "search results when there are more than two call numbers" do
      it "displays View Record for Availability" do
        expect(search_result).to include "View Record for Full Availability"
      end
      it "has an availability icon" do
        expect(search_result).to have_selector ".availability-icon[title='Click on the record for full availability info']"
      end
    end
    context "#holding_block_search" do
      it "returns a good string" do
        expect(search_result).to include call_number
        expect(search_result).to include library
      end
      it "tags the record id" do
        expect(search_result).to have_selector "*[data-availability-record][data-record-id='1']"
      end
      it "tags the holding record id" do
        expect(search_result).to have_selector "*[data-availability-record][data-holding-id='#{holding_id}']"
      end
      it "wraps the record" do
        expect(search_result).to have_selector "*[data-availability-record]"
      end
      it "has an availability icon" do
        expect(search_result).to have_selector ".availability-icon"
      end
      it "link missing label appears when 856s is missing from elf location" do
        expect(search_result).to include "Link Missing"
      end
    end
    context "#holding_block record show" do
      it "returns a good string" do
        expect(show_result).to include call_number
        expect(show_result).to include library
      end
      it "link to call number browse" do
        expect(show_result).to have_link('[Browse]', href: "/browse/call_numbers?q=#{call_number}")
      end
      it "tooltip for the call number browse" do
        expect(show_result).to have_selector "*[title='Browse: #{call_number}']"
      end
      it "tags the holding record id" do
        expect(show_result).to have_selector "*[data-holding-id='#{holding_id}']"
      end
    end
  end
end

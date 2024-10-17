# frozen_string_literal: true
require 'rails_helper'

describe 'requests for Marquand items', type: :feature, requests: true do
  before do
    stub_holding_locations
    stub_delivery_locations
  end

  context 'as a Princeton CAS user' do
    let(:user) { FactoryBot.create(:user) }

    before do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/#{user.uid}?ldap=true")
        .to_return(status: 200, body: { barcode: "22101007797777", patron_group: 'P' }.to_json, headers: {})
      login_as user
    end

    context 'with an unavailable item' do
      it 'does not give the option for ILL' do
        stub_request(:get, "#{Requests.config[:pulsearch_base]}/catalog/9956200533506421/raw")
          .to_return(status: 200, body: { id: '9956200533506421',
                                          holdings_1display: "{\"2219823460006421\":{\"location_code\":\"marquand$stacks\",\"location\":\"Marquand Library\",\"library\":\"Marquand Library\",\"call_number\":\"ND553.P6 D24 2008q Oversize\",\"call_number_browse\":\"ND553.P6 D24 2008q Oversize\",\"items\":[{\"holding_id\":\"2219823460006421\",\"id\":\"2319823440006421\",\"status_at_load\":\"0\",\"barcode\":\"32101068477817\",\"copy_number\":\"1\"}]}}" }.to_json)
        stub_request(:get, "#{Requests.config[:bibdata_base]}/bibliographic/9956200533506421/holdings/2219823460006421/availability.json")
          .to_return(status: 200, body: [{ status_label: 'Unavailable', location: "marquand$stacks" }].to_json)
        stub_request(:get, "#{Requests.config[:bibdata_base]}/locations/holding_locations/marquand$stacks.json")
          .to_return(status: 200, body: { library: { code: "marquand" } }.to_json)
        visit('requests/9956200533506421?aeon=false&mfhd=2219823460006421')
        expect(page).not_to have_content('Request via Partner Library')
        expect(page).to have_content('Contact marquand@princeton.edu for use of this item')
      end
    end
  end
end

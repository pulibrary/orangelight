# frozen_string_literal: true

require 'rails_helper'

describe 'Request Options' do
  before { stub_alma_holding_locations }

  describe 'the request page', js: true do
    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/99113436223506421/holdings/22553672700006421/availability.json")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "https://catalog.princeton.edu/catalog/99113436223506421/raw")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "#{Requests.config['bibdata_base']}/availability?id=99113436223506421")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "#{Requests.config['bibdata_base']}/locations/delivery_locations.json")
        .to_return(status: 200, body: {}.to_json, headers: {})
      visit '/catalog/99113436223506421'
    end

    it 'clicking the request button loads the request page' do
      using_wait_time 5 do
        click_link 'Request'
        expect(current_path).to eq "/requests/99113436223506421"
      end
    end
  end

  describe 'On site access status in non-circulate location', js: true do
    before do
      visit '/catalog/99118600973506421'
    end

    it 'displays a Reading Room Request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).to have_selector('td[data-requestable="true"]')
        expect(page).to have_selector('td[data-aeon="true"]')
      end
    end
  end

  # data-requestable in bibdata is true for all the locations
  # describe 'Unavailable status non-requestable location', js: true do
  #   before do
  #     visit '/catalog/9968900573506421'
  #   end

  #   it 'does not display a request button', unless: in_ci? do
  #     using_wait_time 5 do
  #       expect(page.all('.holding-block').length).to eq 1
  #       expect(page).to have_selector('td[data-requestable="false"]')
  #     end
  #   end
  # end

  describe 'Available status requestable location', js: true do
    before do
      visit '/catalog/9990315453506421'
    end

    it 'does display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Request')).to be_visible
      end
    end
  end

  describe 'Multi-item holding with some requestable items', js: true do
    before do
      visit '/catalog/9960454643506421'
    end

    # This no longer tests for the request button, as CORS headers must be enabled for the bibdata installation to avoid JavaScript/AJAX errors in Chrome
    xit 'does display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Request')).to be_visible
      end
    end
  end
  # This should address borrow direct. eventually
  # If monograph - direct user to borrow direct fallback ILL, Recall
  # If serial - direct user to ILL, fallback Recall
  # describe 'Unavailable status requestable location', js: true do
  #   before(:each) do
  #     visit '/catalog/'
  #   end

  #   it 'does display a request button', unless: in_ci? do
  #     sleep 5.seconds
  #     expect(page.all('.holding-block').length).to eq 1
  #     expect(page.all('.location-services.service-conditional a.btn-primary'.length)).to eq(1)
  #     expect(page.find_link('Request Options').visible?).to be_truthy
  #   end
  # end

  describe 'Aeon location', js: true do
    before do
      visit '/catalog/99118600973506421'
    end

    it 'displays an aeon request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Reading Room Request')).to be_visible
      end
    end
  end
end

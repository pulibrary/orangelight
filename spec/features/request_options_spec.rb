# frozen_string_literal: true

require 'rails_helper'

describe 'Request Options' do
  before { stub_holding_locations }

  describe 'the request page', js: true do
    before do
      visit '/catalog/9618072'
    end

    it 'clicking the request button loads the request page' do
      stub_request(:get, "https://bibdata-staging.princeton.edu/bibliographic/9618072/holdings/9455965/availability.json")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "https://catalog.princeton.edu/catalog/9618072/raw")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "https://bibdata-staging.princeton.edu/availability?id=9618072")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_request(:get, "https://bibdata-staging.princeton.edu/locations/delivery_locations.json")
        .to_return(status: 200, body: {}.to_json, headers: {})
      using_wait_time 5 do
        click_link('Request')
        expect(current_path).to eq "/requests/9618072"
      end
    end
  end

  describe 'the request button when orangelight is in read-only mode', js: true do
    it 'does not display a request button' do
      allow(Orangelight).to receive(:read_only_mode).and_return(true)
      visit '/catalog/9618072'
      using_wait_time 5 do
        expect(page).to have_selector('td[data-requestable="false"]')
      end
    end
  end

  describe 'Available status non-requestable location', js: true do
    before do
      visit '/catalog/9222024'
    end

    it 'does not display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).to have_selector('td[data-requestable="false"]')
      end
    end
  end

  describe 'Unavailable status non-requestable location', js: true do
    before do
      visit '/catalog/6890057'
    end

    it 'does not display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).to have_selector('td[data-requestable="false"]')
      end
    end
  end

  describe 'In process status non-requestable location', js: true do
    before do
      visit '/catalog/9618072'
    end

    it 'does display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Request')).to be_visible
      end
    end
  end

  describe 'Available status requestable location', js: true do
    before do
      visit '/catalog/9031545'
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
      visit '/catalog/6045464'
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
      visit '/catalog/7916044'
    end

    it 'displays an aeon request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Reading Room Request')).to be_visible
      end
    end
  end

  describe 'An In-transit discharged item', js: true do
    before do
      visit '/catalog/9741216'
    end

    it 'does not display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).to have_selector('td[data-requestable="false"]')
      end
    end
  end

  describe 'Paging location available status', js: true do
    before do
      visit '/catalog/8908514'
    end

    xit 'does display a paging request button' do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Paging Request').visible?).to be_truthy
      end
    end
  end

  describe 'Paging location that has been shelved at a temp location status', js: true do
    before do
      visit '/catalog/5318288'
    end

    xit 'does display a request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).not_to have_selector('.location-services.service-conditional')
      end
    end
  end

  describe 'Paging location that has been shelved at a temp location status', js: true do
    before do
      visit '/catalog?search_field=all_fields&q=5318288'
    end

    xit 'does not display a paging request icon', unless: in_ci? do
      using_wait_time 5 do
        expect(page).not_to have_selector('.icon-warning.icon-paging-request')
      end
    end
  end
end

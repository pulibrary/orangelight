# frozen_string_literal: true

require 'rails_helper'

describe 'Request Options', requests: true do
  before { stub_holding_locations }

  describe 'the request page', js: true do
    before do
      stub_availability_by_holding_id(bib_id: '99113436223506421', holding_id: '22553672700006421', body: false)
      stub_catalog_raw(bib_id: '99113436223506421', body: false)
      stub_request(:get, "#{Requests.config['bibdata_base']}/availability?id=99113436223506421")
        .to_return(status: 200, body: {}.to_json, headers: {})
      stub_delivery_locations
      visit '/catalog/99113436223506421'
    end
    # rubocop:disable RSpec/AnyInstance
    context 'as a logged in user' do
      let(:user) { FactoryBot.create(:user) }
      before do
        allow_any_instance_of(Devise::Controllers::StoreLocation).to receive(:stored_location_for)
          .and_return('/catalog/99113436223506421')
        login_as(user)
      end
      it 'clicking the request button loads the request page' do
        using_wait_time 5 do
          click_link 'Request'
          expect(current_path).to eq "/requests/99113436223506421"
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end

  describe 'On site access status in non-circulate location', js: true do
    before do
      visit '/catalog/99118600973506421'
    end

    # need to be on VPN for this test to pass
    it 'displays a Reading Room Request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page).to have_selector('td[data-requestable="true"]')
        expect(page).to have_selector('td[data-aeon="true"]')
      end
    end
  end

  describe 'Available status requestable location', js: true do
    before do
      visit '/catalog/9990315453506421'
    end

    # need to be on VPN for this test to pass
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
  end

  describe 'Aeon location', js: true do
    before do
      visit '/catalog/99118600973506421'
    end

    # need to be on VPN for this test to pass
    it 'displays an aeon request button', unless: in_ci? do
      using_wait_time 5 do
        expect(page.all('.holding-block').length).to eq 1
        expect(page.find_link('Reading Room Request')).to be_visible
      end
    end
  end
end

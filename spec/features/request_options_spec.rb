# frozen_string_literal: true

require 'rails_helper'

describe 'Request Options' do
  before { stub_holding_locations }

  describe 'Available status non-requestable location', js: true do
    before do
      visit '/catalog/9222024'
    end

    it 'does not display a request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page).not_to have_selector('.location-services.service-conditional')
    end
  end

  describe 'Unavailable status non-requestable location', js: true do
    before do
      visit '/catalog/6890057'
    end

    it 'does not display a request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page).not_to have_selector('.location-services.service-conditional')
    end
  end

  describe 'In process status non-requestable location', js: true do
    before do
      visit '/catalog/9618072'
    end

    it 'does display a request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page.find_link('Request')).to be_visible
    end
  end

  describe 'Available status requestable location', js: true do
    before do
      visit '/catalog/9031545'
    end

    it 'does display a request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page.find_link('Request')).to be_visible
    end
  end

  describe 'Multi-item holding with some requestable items', js: true do
    before do
      visit '/catalog/6045464'
    end

    it 'does display a request button', unless: in_ci? do
      sleep 10.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page.find_link('Request')).to be_visible
    end
  end
  # This should address borrow direct. evenutally
  # If monograph - direct user to borrow direct fallback ILL, Recall
  # If serial - direct user to ILL, fallback Recall
  # describe 'Unavailable status requestable location', js: true do
  #   before(:each) do
  #     visit '/catalog/'
  #   end

  #   it 'does display a request button', unless: in_travis? do
  #     sleep 5.seconds
  #     expect(page.all('.location--holding').length).to eq 1
  #     expect(page.all('.location-services.service-conditional a.btn-primary'.length)).to eq(1)
  #     expect(page.find_link('Request Options').visible?).to be_truthy
  #   end
  # end

  describe 'Aeon location', js: true do
    before do
      visit '/catalog/7916044'
    end

    it 'displays an aeon request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page.find_link('Reading Room Request')).to be_visible
    end
  end

  describe 'An In-transit discharged item', js: true do
    before do
      visit '/catalog/9741216'
    end

    it 'does not display a request button', unless: in_ci? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
      expect(page).not_to have_selector('.location-services.service-conditional')
    end
  end

  # describe 'Paging location available status', js: true do
  #   before(:each) do
  #     visit '/catalog/8908514'
  #   end

  #   it 'does display a paging request button', unless: in_travis? do
  #     sleep 5.seconds
  #     expect(page.all('.location--holding').length).to eq 1
  #     expect(page.find_link('Paging Request').visible?).to be_truthy
  #   end
  # end

  # describe 'Paging location that has been shelved at a temp location status', js: true do
  #   before(:each) do
  #     visit '/catalog/5318288'
  #   end

  #   it 'does display a request button', unless: in_travis? do
  #     sleep 5.seconds
  #     expect(page.all('.location--holding').length).to eq 1
  #     expect(page).not_to have_selector('.location-services.service-conditional')
  #   end
  # end

  # describe 'Paging location that has been shelved at a temp location status', js: true do
  #   before(:each) do
  #     visit '/catalog?search_field=all_fields&q=5318288'
  #   end

  #   it 'does not display a paging request icon', unless: in_travis? do
  #     sleep 5.seconds
  #     expect(page).not_to have_selector('.icon-warning.icon-paging-request')
  #   end
  # end
end

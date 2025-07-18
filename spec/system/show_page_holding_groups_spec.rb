# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Holding groups on the show page', js: true do
  it 'summarizes the holdings within the group' do
    stub_holding_locations
    visit '/catalog/99122643653506421'
    within 'summary', text: 'Lewis Library - Stacks' do
      expect(page).to have_selector '.lux-badge', text: /Some Available/i, wait: 10
    end
  end

  it 'does not show a summary for open groups' do
    stub_holding_locations
    visit '/catalog/99122643653506421'
    within 'summary', text: 'Lewis Library - Course Reserve' do
      expect(page).to have_no_selector '.lux-badge'
    end
  end
end

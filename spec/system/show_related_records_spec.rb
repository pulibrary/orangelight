# frozen_string_literal: true

require 'rails_helper'

describe 'Show related records', type: :system, js: true do
  before do
    stub_holding_locations
    visit '/catalog/99124945733506421'
  end

  it 'shows 3 related records by default' do
    expect(page).to have_selector('ul#linked-records-related_record_s li', count: 3)
  end

  it 'shows all related records when the button is pressed and sets focus' do
    click_button 'Show 10 more related records'
    expect(page).to have_selector('ul#linked-records-related_record_s li', count: 13)
    sleep 2
    expect(page.evaluate_script("document.activeElement.id")).to eq('linked-records-related_record_s')
  end

  it 'can toggle back to 3 related records' do
    click_button 'Show 10 more related records'
    sleep 1
    click_button 'Show fewer related records'
    expect(page).to have_selector('ul#linked-records-related_record_s li', count: 3)
  end
end

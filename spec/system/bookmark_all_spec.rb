# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Bookmark all', :bookmarks, js: true do
  it 'allows you to bookmark all documents on a page at once' do
    stub_holding_locations
    visit '/'
    fill_in :q, with: '1Q84'
    click_button 'Search'
    expect(page).to have_button exact_text: 'Bookmark', count: 4
    expect(page).not_to have_button exact_text: 'In Bookmarks'

    expect do
      click_button 'Bookmark all'
      expect(page).not_to have_button exact_text: 'Bookmark'
      expect(page).to have_button exact_text: 'In Bookmarks', count: 4
    end.to change(Bookmark, :count).by 4
  end
end

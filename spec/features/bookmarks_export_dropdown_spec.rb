# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks export dropdown', type: :feature do
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_holding_locations
    login_as user
    Bookmark.create!(user: user, document_id: '99122304923506421', document_type: 'SolrDocument')
    Bookmark.create!(user: user, document_id: '99122643653506421', document_type: 'SolrDocument')
  end

  it 'preserves search params in export actions' do
    visit bookmarks_path(q: '99122304923506421')
    within('.search-widgets') do
      click_button 'Export'
      expect(page).to have_link('Print')
      expect(page).to have_link('Email')
      expect(page).to have_link('CSV')
      print_link = find_link('Print')[:href]
      email_link = find_link('Email')[:href]
      csv_link = find_link('CSV')[:href]
      expect(print_link).to include('q=99122304923506421')
      expect(email_link).to include('q=99122304923506421')
      expect(csv_link).to include('q=99122304923506421')
      expect(print_link).not_to include('q=99122643653506421')
      expect(email_link).not_to include('q=99122643653506421')
      expect(csv_link).not_to include('q=99122643653506421')
    end
  end
end

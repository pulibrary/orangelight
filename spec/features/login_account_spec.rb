# frozen_string_literal: true
require 'rails_helper'

describe 'Account login' do
  let(:user) { FactoryBot.create(:user) }
  let(:alma_account_url) { "https://princeton.alma.exlibrisgroup.com/discovery/account?vid=01PRI_INST:Services&lang=EN&section=overview" }

  describe 'Your Account menu', js: true do
    it "lists correct options when not logged in" do
      visit "/"
      click_button("Your Account")
      within('li.show') do
        link = find_link("Library Account")
        expect(link[:href]).to eq alma_account_url
        expect(link[:target]).to eq("_blank")
        expect(has_css?('i.fa-external-link', count: 1)).to eq true
        expect(page).to have_link("Digitization Requests", href: digitization_requests_path)
        expect(page).to have_link("Bookmarks", href: bookmarks_path)
        expect(page).to have_link("Search History", href: blacklight.search_history_path)
        expect(page).not_to have_link("Log Out")
      end
    end

    it "lists correct options when logged in" do
      login_as user
      visit "/"
      click_button(user.username)
      within('li.show') do
        link = find_link("Library Account")
        expect(link[:href]).to eq alma_account_url
        expect(link[:target]).to eq("_blank")
        expect(has_css?('i.fa-external-link', count: 1)).to eq true
        expect(page).to have_link("Digitization Requests", href: digitization_requests_path)
        expect(page).to have_link("Bookmarks", href: bookmarks_path)
        expect(page).to have_link("Search History", href: blacklight.search_history_path)
        expect(page).to have_link("Log Out")
      end
    end
  end
end

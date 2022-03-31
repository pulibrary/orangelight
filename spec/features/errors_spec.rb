# frozen_string_literal: true

require 'rails_helper'

describe 'errors' do
  describe '404 page' do
    it 'is customized' do
      # Haven't been able to get the "show instead of exceptions" thing working in tests, but this at least makes sure the page can render correctly.
      visit '/404'
      expect(page.status_code).to eq 404
      expect(page).to have_content("The page you were looking for doesn't exist")
      expect(page).to have_selector(:css, 'a[href="mailto:catalog-feedback@princeton.libanswers.com"]')
    end
  end

  describe '500 page' do
    it "when there is an Internal Server Error" do
      visit '/500'
      expect(page.status_code).to eq 500
      expect(page).to have_content("We're sorry, but there was a problem processing the page you requested")
      expect(page).to have_selector(:css, 'a[href="mailto:catalog-feedback@princeton.libanswers.com"]')
    end
  end

  describe 'response to Blacklight::Exceptions::RecordNotFound exception' do
    it 'redirects to the 404 page' do
      visit '/catalog/3861539wrong'
      expect(page.status_code).to eq 404
      expect(page).to have_selector(:css, 'a[href="mailto:catalog-feedback@princeton.libanswers.com"]')
    end
  end
end

require 'rails_helper'

describe 'errors' do
  describe '404 page' do
    it 'is customized' do
      # Haven't been able to get the "show instead of exceptions" thing working in tests, but this at least makes sure the page can render correctly.
      visit '/404'
      expect(page.status_code).to eq 404
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end

  describe 'response to Blacklight::Exceptions::RecordNotFound exception' do
    it 'redirects to the 404 page' do
      visit '/catalog/3861539wrong'
      expect(page.status_code).to eq 404
    end
  end
end

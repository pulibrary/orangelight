require 'rails_helper'

describe 'Browsables' do
  describe 'Browse by Call Number' do
    it 'displays two browse entries before exact match' do
      visit 'browse/call_numbers?q=PL856.U673+A61213+2011'
      expect(page.all('tr')[3][:class]).to eq('alert alert-info')
    end
  end
end

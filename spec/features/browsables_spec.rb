# frozen_string_literal: true

require 'rails_helper'

describe 'Browsables' do
  describe 'Browse by Call Number' do
    before do
      visit '/browse/call_numbers?q=PN842+.S539+2006&rpp=10'
    end
    it 'displays two browse entries before exact match' do
      expect(page.all('tr')[3][:class]).to eq('alert alert-info clickable-row')
    end
    it 'has a call number link' do
      expect(page.all('tr')[3]).to have_xpath("//a", text: "PN842 .S539 2006")
    end
    it 'has the library name if it exists' do
      expect(page).to have_xpath('//*[@id="content"]/table/tbody/tr[3]//td[2]', text: 'Firestone Library - Near East Collections')
    end
  end

  describe 'Browse by author-title heading' do
    before(:all) do
      stub_holding_locations
      stub_hathi
      visit '/catalog/9982377783506421'
    end
    it 'name-uniform title link, hierarchical, does not display name' do
      brahms = 'Brahms, Johannes, 1833-1897.'
      title = 'Piano music.'
      browse_title = StringFunctions.trim_punctuation("#{brahms} #{title}")
      title_part = 'Selections'
      browse_title_part = "#{brahms} #{title} #{title_part}"
      expect(page).to have_link(title, href: "/?f[name_title_browse_s][]=#{CGI.escape browse_title}")
      expect(page).to have_link(title_part, href: "/?f[name_title_browse_s][]=#{CGI.escape browse_title_part}")
      expect(page).to have_link('[Browse]', href: "/browse/name_titles?q=#{CGI.escape browse_title_part}")
    end
  end
end

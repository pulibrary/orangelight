# frozen_string_literal: true

require 'rails_helper'

describe 'Browsables', browse: true do
  describe 'Browse by Call Number' do
    context 'with an LC call number' do
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
    context 'with oversize CDs' do
      before do
        visit '/browse/call_numbers?search_field=browse_cn&q=CD-+40056q'
      end

      it 'sorts Oversize CDs with other CDs' do
        within(:xpath, '//*[@id="content"]/table/tbody') do
          expect(page.find('tr[2]/td[1]/a').text).to eq("CD- 40055")
          expect(page.find('tr[3]')).to match_css('.alert.alert-info.clickable-row')
          expect(page.find('tr[3]//td[1]').text).to eq("CD- 40056q Oversize")
          expect(page.find('tr[4]/td[1]/a').text).to eq("CD- 40057")
        end
      end
    end
  end

  describe 'Browse by author-title heading' do
    before(:all) do
      stub_holding_locations
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

  describe 'Browse subject links' do
    before do
      stub_holding_locations
      visit '/catalog/9982377783506421'
    end
    it "browses a subject heading link" do
      subject_heading_lc1 = "Piano music"
      expect(page).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape subject_heading_lc1}&vocab=lc_subject_facet")
    end
    it "browses a subject heading with subdivision link" do
      subject_heading_lc_with_subdivision = "Concertos (Piano)—Cadenzas"
      expect(page).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape subject_heading_lc_with_subdivision}&vocab=lc_subject_facet")
    end
  end

  describe 'subject browse search results' do
    before do
      stub_holding_locations
      visit '/catalog/99131369190806421'
    end
    it 'if there are more than one results it highlights the search target value' do
      subject_heading_lc1 = "Fairy tales"
      expect(page).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape subject_heading_lc1}&vocab=lc_subject_facet")

      click_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape subject_heading_lc1}&vocab=lc_subject_facet")

      expect(page).to have_content('fairy tales')
      within('.alert.alert-info') do
        expect(page).to have_content('Fairy tales')
      end
    end
  end

  describe 'Search subject links' do
    before do
      stub_holding_locations
      visit '/catalog/9961398363506421'
    end
    it "searches a subject heading" do
      subject_heading_lc1 = "Menz family—Art patronage—Exhibitions"
      expect(page).to have_link('Exhibitions', href: "/?f[lc_subject_facet][]=#{CGI.escape subject_heading_lc1}")
    end
    it "searches a subject heading with subdivision" do
      subject_heading_lc_subdivision = "Art patronage"
      subject_heading_lc_with_subdivision = "Menz family—Art patronage"
      expect(page).to have_link(subject_heading_lc_subdivision, href: "/?f[lc_subject_facet][]=#{CGI.escape subject_heading_lc_with_subdivision}")
    end
  end
end

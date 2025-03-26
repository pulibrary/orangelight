# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :feature, js: true do
  before do
    stub_holding_locations
  end
  context "home page" do
    before do
      visit "/"
    end

    it "complies with wcag" do
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
    end
  end

  context "record page" do
    before do
      visit "catalog/9931488793506421"
    end
    it "complies with wcag2aa wcag21a" do
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
    end
  end
  context 'search results page' do
    before do
      allow(Flipflop).to receive(:highlighting?).and_return(true)
    end

    it 'complies with wcag2aa wcag21aa' do
      visit '/catalog?q=black+teenagers'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
    end
  end
  context "browse list page" do
    it 'complies with wcag2aa wcag21aa next button' do
      pending('increase contrast for next button when on the last page and disabled')
      visit '/browse/call_numbers?rpp=10&start=10619849'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        # Issue: https://github.com/pulibrary/orangelight/issues/4837
        .excluding('.next')
    end
    it 'complies with wcag2aa wcaf21aa links and more info' do
      pending('increase contrast for links and the more info status when on a gray background')
      visit '/browse/call_numbers?q=PN842+.S539+2006&rpp=10'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        # Issue: https://github.com/pulibrary/orangelight/issues/4838
        .excluding('.more-info.bg-secondary')
        # Issue: https://github.com/pulibrary/orangelight/issues/4839
        .excluding('#content a')
    end
    it 'complies with wcag2aa wcag 21aa for the next button when disabled' do
      
      
      visit '/browse/call_numbers?rpp=10&start=10619849'
      expect(page).to be_axe_clean.within '.next'
    end
    it 'complies with wcag2aa wcag 21aa for the more info status element' do
      
      pending('increase contrast for gray more info status text on gray background in the location column')
      visit '/browse/call_numbers?q=PN842+.S539+2006&rpp=10'
      expect(page).to be_axe_clean
        .within('.more-info.badge[data-record-id="SCSB-2635660"]')
    end
    it 'complies with wcag2aa wcag 21aa for the call number link' do
      
      pending('increase contrast for blue link text on gray background in the call number column')
      visit '/browse/call_numbers?q=PN842+.S539+2006&rpp=10'
      expect(page).to be_axe_clean.within 'a[href="/catalog/9947994363506421"]'
    end
  end
end

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
  context "browse list page" do
    it 'complies with wcag2aa wcag21aa next button' do
      # Issue: https://github.com/pulibrary/orangelight/issues/4837
      pending('increase contrast for next button when on the last page and disabled')
      visit '/browse/call_numbers?rpp=10&start=10619849'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
    end
    it 'complies with wcag2aa wcaf21aa links and more info' do
      # Issue: https://github.com/pulibrary/orangelight/issues/4838
      # Issue: https://github.com/pulibrary/orangelight/issues/4839
      pending('increase contrast for links and the more info status when on a gray background')
      visit '/browse/call_numbers?q=PN842+.S539+2006&rpp=10'
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
    end
  end
end

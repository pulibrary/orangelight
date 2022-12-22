# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :feature, js: true do
  before do
    stub_alma_holding_locations
  end
  context "home page" do
    before do
      visit "/"
    end

    it "complies with wcag" do
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding('a[title="Opens in a new tab"][target="_blank"]')
        .excluding('p > a[href$="dataset"]')
    end
  end

  context "record page" do
    before do
      visit "catalog/9931488793506421"
    end
    it "complies with wcag2aa wcag21a" do
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .excluding('#startOverLink')
        .excluding('a[title="Opens in a new tab"]')
        .excluding('.blacklight-series_display[dir="ltr"]:nth-child(1) > .more-in-series[title=""][data-toggle="tooltip"]')
    end
  end
end

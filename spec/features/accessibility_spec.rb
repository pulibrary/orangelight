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
    end
  end

  context "record page" do
    before do
      visit "catalog/9931488793506421"
    end
    it "complies with wcag2aa wcag21a" do
      expect(page).to be_axe_clean
        .according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
        .skipping("link-name") # Issue https://github.com/pulibrary/orangelight/issues/2799
    end
  end
end

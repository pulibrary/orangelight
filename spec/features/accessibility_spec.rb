# frozen_string_literal: true
require "rails_helper"

describe "accessibility", type: :feature, js: true do
  context "home page" do
    it "complies with ..." do
      visit "/"

      expect(page).to be_axe_clean
    end
  end
end
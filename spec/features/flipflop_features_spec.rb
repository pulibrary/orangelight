# frozen_string_literal: true
require 'rails_helper'

describe "Flipflop features" do
  before do
    login_as(user)
  end
  context "as an admin user" do
    let(:user) { FactoryBot.create(:admin) }

    it "has a dashboard" do
      visit 'features'
      expect(page).to have_content("Orangelight Features")
    end
  end
  context "as a regular user" do
    let(:user) { FactoryBot.create(:user) }

    it "does not show the dashboard" do
      visit 'features'
      expect(page.status_code).to eq(403)
    end
  end
end

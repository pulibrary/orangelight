# frozen_string_literal: true
require 'rails_helper'

describe "Flipflop features" do
  it "has a dashboard" do
    visit 'features'
    expect(page).to have_content("Orangelight Features")
  end
end

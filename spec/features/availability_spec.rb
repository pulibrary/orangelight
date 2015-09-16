require 'rails_helper'

describe "Availability"  do

  before(:each) do
    visit  "/catalog/3256177"
  end

  describe "Holdings are rendered" do
    xit "displays some holdings availability" do
      expect(page.all('.umlaut-holdings').length).to eq 1
    end

    xit "displays individual holding listing" do
      expect(page.all('.umlaut-holding').length).to eq 5
    end
  end



end
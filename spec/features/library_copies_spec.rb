require 'rails_helper'

describe "Copies in Library"  do

  describe "are displayed on a record page", js: true do

    before(:each) do
      visit  "/catalog/3256177"
    end

    it "under the heading Copies in Library", unless: $in_travis do
      sleep 5.seconds
      expect(page.all('.section_heading').length).to eq 1
      expect(page.has_text? ('Copies in Library'))
    end

    it "within the holdings section", unless: $in_travis do
      sleep 5.seconds
      expect(page.all('.umlaut-holdings').length).to eq 1
    end

    it "listing invidividual holdings", unless: $in_travis do
      sleep 5.seconds
      expect(page.all('.umlaut-holding').length).to eq 5
    end

    xit "with individual copies display", unless: $in_travis do
      # Add via Bib data
    end
  end

end
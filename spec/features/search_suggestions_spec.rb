require 'rails_helper'

describe "Spelling a search term incorrectly" do
  it "provides a search term suggestion that returns results" do
    visit  "/catalog?search_field=all_fields&q=serching+modern+esthetic"
    expect(page.all('.document').length).to eq 0
    expect(page.has_content?("Did you mean to type: searching modern aesthetic?")).to eq true
    click_link "searching modern aesthetic"
    expect(page.all('.document').length).to eq 1        
  end
end

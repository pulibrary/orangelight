require 'rails_helper'

describe "Zotero Support via Context Objects"  do

  xit "is available on the search results page" do
    visit "/?f%5Baccess_facet%5D%5B%5D=At+the+Library"
    expect(page.all('.Z3988').length).to eq 20
  end

  it "is available on the individual record page" do
    visit "/catalog/9031545"
    expect(page.all('.Z3988').length).to eq 1
  end

  it "Has a context object referencing the bib ID" do
    visit "/catalog/9031545"
    expect(page.find('span.Z3988')[:title]).to have_text('9031545')
  end

end

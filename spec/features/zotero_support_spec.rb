# frozen_string_literal: true

require 'rails_helper'

describe 'Zotero Support via Context Objects', zotero: true do
  before do
    stub_holding_locations
  end

  it 'is available on the search results page' do
    visit '/catalog?search_field=all_fields&q=history'
    expect(page.all('.Z3988').length).to eq 20
  end

  it 'is available on the individual record page' do
    visit '/catalog/9990315453506421'
    expect(page.all('.Z3988').length).to eq 1
  end

  it 'is available on an individual SCSB record page' do
    visit '/catalog/SCSB-2143785'
    expect(page.all('.Z3988').length).to eq 1
  end

  it 'Has a context object referencing the bib ID' do
    visit '/catalog/9990315453506421'
    expect(page.find('span.Z3988')[:title]).to have_text('9990315453506421')
  end

  it 'Does not include the rft.date parameter when the record format is journal' do
    visit '/catalog/998574693506421'
    expect(page.find('span.Z3988')[:title]).not_to have_text('rft.date')
  end

  it 'Does not include the rft.date parameter for non-journal formats' do
    visit '/catalog/9990315453506421'
    expect(page.find('span.Z3988')[:title]).to have_text('rft.date')
  end

  # To fix RIS URL Export bug: https://github.com/pulibrary/orangelight/issues/2321
  it "has a url in the UR field" do
    visit '/catalog/9945502073506421.ris'
    coins_fields = page.body.split(/\n/)
    ur_field = coins_fields.select { |x| x.split(" - ").first == "UR" }
    key, value = ur_field.first.split(" - ")
    expect(key).to eq "UR"
    expect(value).to eq "http://www.loc.gov/catdir/description/cam051/2004018645.html"
  end
end

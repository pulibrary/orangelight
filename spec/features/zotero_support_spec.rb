# frozen_string_literal: true

require 'rails_helper'

describe 'Zotero Support via Context Objects' do
  before { stub_holding_locations }

  it 'is available on the individual record page' do
    visit '/catalog/9031545'
    expect(page.all('.Z3988').length).to eq 1
  end

  it 'Has a context object referencing the bib ID' do
    visit '/catalog/9031545'
    expect(page.find('span.Z3988')[:title]).to have_text('9031545')
  end

  it 'Does not include the rft.date parameter when the record format is journal' do
    visit '/catalog/857469'
    expect(page.find('span.Z3988')[:title]).not_to have_text('rft.date')
  end

  it 'Does not include the rft.date parameter for non-journal formats' do
    visit '/catalog/9031545'
    expect(page.find('span.Z3988')[:title]).to have_text('rft.date')
  end
end

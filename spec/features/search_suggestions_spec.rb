# frozen_string_literal: true

require 'rails_helper'

describe 'Spelling a search term incorrectly' do
  it 'provides a search term suggestion that returns results' do
    stub_holding_locations
    visit '/catalog?search_field=all_fields&q=serching+modern+esthetic'
    expect(page.all('.document').length).to eq 0
    expect(page.has_content?('Did you mean to type: searching modern aesthetic?')).to eq false
    expect(page.all('.document').length).to eq 0
  end
end

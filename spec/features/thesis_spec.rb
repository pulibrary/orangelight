# frozen_string_literal: true

require 'rails_helper'

describe 'Viewing on-site thesis record' do
  it 'provides link to Mudd website' do
    stub_holding_locations
    visit  '/catalog/dsp01tq57ns24j'
    within 'dd.blacklight-rights_reproductions_note_display' do
      find_link 'Mudd Manuscript Library'
    end
  end
end

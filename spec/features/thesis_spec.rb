require 'rails_helper'

describe 'Viewing on-site thesis record' do
  it 'provides link to Mudd website' do
    visit  '/catalog/dsp01tq57ns24j'
    within 'dd.blacklight-rights_reproductions_note_display' do
      find_link 'Mudd Manuscript Library'
    end
  end
end

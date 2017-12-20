require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:location_has_note) { helper.location_has(field_config) }
  let(:document_single_note) do
    {
      id: '1',
      holdings_1display: '{"2":{"location_has":["Note"]}}'
    }.with_indifferent_access
  end
  let(:document_multiple_notes) do
    {
      id: '1',
      holdings_1display: '{"3":{"location_has":["Note","More"]}}'
    }.with_indifferent_access
  end
  let(:field_config) do
    {
      field: :format,
      document: document
    }.with_indifferent_access
  end

  describe '#location_has' do
    describe 'with a single note' do
      let(:document) { document_single_note }

      it 'returns an array with the single note' do
        expect(location_has_note).to eq(['Note'])
      end
    end
    describe 'with multiple notes' do
      let(:document) { document_multiple_notes }

      it 'returns a ul with the notes' do
        expect(location_has_note).to eq('<ul><li>Note</li><li>More</li></ul>')
      end
    end
  end
end

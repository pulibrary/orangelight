require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#locate_link helpers' do
    let(:stackmap_location) { 'f' }
    let(:stackmap_ineligible_location) { 'annexa' }
    let(:bib) { '123456' }
    let(:call_number) { 'RCPXR-6136516' }
    let(:stackmap_library) { 'Firestone' }
    let(:stackmap_ineligible_library) { 'Fine Annex' }

    it 'Returns a Stackmap Link for a Mapping Location' do
      stackmap_link = locate_link(stackmap_location, bib, call_number, stackmap_library)
      expect(stackmap_link).to be_truthy
      expect(stackmap_link).to include("#{ENV['stackmap_base']}?loc=#{stackmap_location}&amp;id=#{bib}")
    end

    it 'Does not return a stackmap link for an inaccessible location' do
      stackmap_link = locate_link(stackmap_ineligible_location, bib, call_number, stackmap_ineligible_library)
      expect(stackmap_link).to eq('')
    end

    it 'Does not return a stackmap link when there is no call number' do
      stackmap_link = locate_link(stackmap_location, bib, nil, stackmap_library)
      expect(stackmap_link).to eq('')
    end
  end

  describe '#render_location_code' do
    it 'returns value when value is not a valid location code' do
      value = 'blah'
      expect(render_location_code(value)).to eq value
    end

    it 'renders full location when value is a valid location code' do
      expect(render_location_code('clas')).to eq('clas: Firestone Library - Classics Collection')
    end
  end

  describe '#holding_location_label' do
    let(:fallback) { 'Fallback' }
    let(:without_code) { { 'location' => fallback } }
    let(:invalid_code) { { 'location' => fallback, 'location_code' => 'invalid' } }
    let(:valid_code) { { 'location' => fallback, 'location_code' => 'clas' } }

    it 'returns holding location label when location code lookup successful' do
      expect(holding_location_label(valid_code)).to eq('Firestone Library - Classics Collection')
    end
    it 'returns holding location value when location code lookup fails' do
      expect(holding_location_label(invalid_code)).to eq(fallback)
    end
    it 'returns holding location value when no location code' do
      expect(holding_location_label(without_code)).to eq(fallback)
    end
    it 'returns nil when no location code or holding location value' do
      expect(holding_location_label({})).to be_nil
    end
  end

  describe '#open_location?' do
    let(:loc) { { open: true } }
    let(:holding) { { 'call_number_browse' => 'KF 1232 .B2', 'location_code' => 'f' } }
    it 'returns the location open attribute value' do
      expect(open_location?(loc)).to eq true
    end
    it 'returns false when nil location is passed to function' do
      expect(open_location?(nil)).to eq false
    end
  end

  describe '#aeon_location?' do
    let(:loc) { { aeon_location: true } }
    it 'returns the location aeon_location attribute value' do
      expect(aeon_location?(loc)).to eq true
    end
    it 'returns false when nil location is passed to function' do
      expect(aeon_location?(nil)).to eq false
    end
  end

  describe '#current_year' do
    it 'returns the current year' do
      expect(current_year).to eq DateTime.now.year
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe MultiselectComboboxComponent, type: :component do
  subject do
    render_inline(described_class.new(label: 'Format',
                                      dom_id: 'format',
                                      field_name: 'format',
                                      values: [
                                        { value: 'Book', label: 'Book (12)', selected: false },
                                        { value: 'Map', label: 'Map (8)', selected: true }
                                      ]))
  end
  it "renders a label with the given label and domId" do
    label = subject.css('label')
    expect(label.text).to eq('Format')
    expect(label.attr('for').value).to eq('format')
  end

  describe 'input' do
    let(:input) { subject.css('input') }
    it "uses the given domId as its id" do
      expect(input.attr('id').value).to eq('format')
    end
    it "controls the listbox" do
      expect(input.attr('aria-controls').value).to eq('format-list')
    end
  end

  describe 'listbox' do
    let(:listbox) { subject.css('ul') }
    it "contains an option for each value provided" do
      expect(listbox.css('li').length).to eq(2)
      expect(listbox.css('li')[0].text).to eq('Book (12)')
      expect(listbox.css('li')[1].text).to eq('Map (8)')
    end
  end

  describe 'aria-live region' do
    let(:aria_live_region) { subject.css('.number-of-results[aria-live="polite"]') }
    it "includes the number of results" do
      expect(aria_live_region.text).to include('2 options.')
    end
    it "includes instructions for the user" do
      expect(aria_live_region.text).to include('Press down arrow for options.')
    end
  end
end

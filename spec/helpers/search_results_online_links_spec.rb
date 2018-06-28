# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#electronic_access_link' do
    let(:link_markup) { electronic_access_link('http://arks.princeton.edu/ark:/88435/dsp01ft848s955', ['Full text']) }

    it 'generates electronic access links for a catalog record' do
      expect(link_markup).to include '<a target="_blank"'
      expect(link_markup).to include 'href="https://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/ark:/88435/dsp01ft848s955"'
      expect(link_markup).to include 'Full text'
    end

    context 'with an open access record' do
      let(:link_markup) { electronic_access_link('http://hdl.handle.net/1802/27831', ['Open access']) }

      it 'generates electronic access links for a catalog record without a proxy' do
        expect(link_markup).to include '<a target="_blank"'
        expect(link_markup).to include 'href="http://hdl.handle.net/1802/27831"'
        expect(link_markup).to include 'Open access'
      end
    end

    context 'with a link to the IIIF Viewer' do
      let(:link_markup) { electronic_access_link('https://pulsearch.princeton.edu/catalog/4609321#view', ['arks.princeton.edu']) }

      it 'generates electronic access links for a catalog record which link to the IIIF Viewer' do
        expect(link_markup).to include '<a href="/catalog/4609321#view"'
        expect(link_markup).to include 'Digital content'
      end
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::HoldingGroup do
  describe 'sorting for display' do
    it 'sorts branch libraries before remote locations' do
      stokes = described_class.new(group_name: 'Stokes Library - New Book Shelf', holdings: [])
      recap = described_class.new(group_name: 'Remote Storage (ReCAP): Historic Maps. Special Collections Use Only', holdings: [])
      forrestal = described_class.new(group_name: 'Forrestal Annex - Stacks', holdings: [])
      lewis_off_site = described_class.new(group_name: 'Lewis Library - Serials (Off-Site)', holdings: [])

      expect(stokes).to be < recap
      expect(recap).to be > stokes

      expect(stokes).to be < forrestal
      expect(forrestal).to be > stokes

      expect(stokes).to be < lewis_off_site
      expect(lewis_off_site).to be > stokes
    end
  end
end

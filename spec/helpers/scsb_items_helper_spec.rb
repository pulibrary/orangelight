# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#scsb_supervised_items?' do
    let(:all_supervised) { helper.scsb_supervised_items?(all_supervised_items) }
    let(:some_supervised) { helper.scsb_supervised_items?(some_supervised_items) }
    let(:none_supervised) { helper.scsb_supervised_items?(no_supervised_items) }
    let(:all_supervised_items) {
      {
        'location' => 'ReCAP',
        'library' => 'ReCAP',
        'location_code' => 'scsbnypl',
        'items' => [
          { 'holding_id' => '7985322',
            'use_statement' => 'Supervised Use',
            'barcode' => '33433098463957',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' },
          { 'holding_id' => '7985322',
            'use_statement' => 'Supervised Use',
            'barcode' => '33433091627434',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' }
        ]
      }
    }
    let(:some_supervised_items) {
      {
        'location' => 'ReCAP',
        'library' => 'ReCAP',
        'location_code' => 'scsbnypl',
        'items' => [
          { 'holding_id' => '7985322',
            'use_statement' => 'In Library Use',
            'barcode' => '33433098463957',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' },
          { 'holding_id' => '7985322',
            'use_statement' => 'Supervised Use',
            'barcode' => '33433091627434',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' }
        ]
      }
    }
    let(:no_supervised_items) {
      {
        'location' => 'ReCAP',
        'library' => 'ReCAP',
        'location_code' => 'scsbnypl',
        'items' => [
          { 'holding_id' => '7985322',
            'use_statement' => '',
            'barcode' => '33433098463957',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' },
          { 'holding_id' => '7985322',
            'use_statement' => '',
            'barcode' => '33433091627434',
            'copy_number' => '1',
            'cgc' => 'Shared',
            'collection_code' => 'NA' }
        ]
      }
    }

    it 'returns true when all items are marked for supervised use' do
      expect(all_supervised).to be true
    end

    it 'returns false when some items are marked for supervised use' do
      expect(some_supervised).to be false
    end

    it 'returns false when all items are not marked for supervised use' do
      expect(none_supervised).to be false
    end
  end
end

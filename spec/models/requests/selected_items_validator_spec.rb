# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::SelectedItemsValidator do
  let(:validator) { described_class.new({}) }
  let(:record) { instance_double(Requests::Submission, errors: ActiveModel::Errors.new(self), items: []) }

  describe '#validate_user_supplied_enum_for_print' do
    it 'adds an error when selected, print delivery, and user_supplied_enum is blank' do
      selected_item = {
        'selected' => 'true',
        'item_id' => '123',
        'delivery_mode_123' => 'print',
        'user_supplied_enum' => ''
      }
      expect do
        validator.send(:validate_user_supplied_enum_for_print, record, selected_item)
      end.to change { record.errors[:items].size }.by(1)
      expect(record.errors[:items]).to include('Please specify the volume/part/issue information for your request.')
    end

    it 'does not add error when user_supplied_enum is present' do
      selected_item = {
        'selected' => 'true',
        'item_id' => '123',
        'delivery_mode_123' => 'print',
        'user_supplied_enum' => 'Vol. 1'
      }
      expect do
        validator.send(:validate_user_supplied_enum_for_print, record, selected_item)
      end.not_to(change { record.errors[:items].size })
    end

    it 'does not add error when not selected' do
      selected_item = {
        'selected' => 'false',
        'item_id' => '123',
        'delivery_mode_123' => 'print',
        'user_supplied_enum' => ''
      }
      expect do
        validator.send(:validate_user_supplied_enum_for_print, record, selected_item)
      end.not_to(change { record.errors[:items].size })
    end

    it 'does not add error when delivery_type is not print' do
      selected_item = {
        'selected' => 'true',
        'item_id' => '123',
        'delivery_mode_123' => 'edd',
        'user_supplied_enum' => ''
      }
      expect do
        validator.send(:validate_user_supplied_enum_for_print, record, selected_item)
      end.not_to(change { record.errors[:items].size })
    end
  end
end

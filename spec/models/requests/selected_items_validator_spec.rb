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

  describe "'recap_marquand' items" do
    let(:record) do
      instance_double(
        Requests::Submission,
        errors: ActiveModel::Errors.new(self),
        items: items
      )
    end

    let(:valid_print_item) do
      {
        'selected' => 'true',
        'type' => 'recap_marquand',
        'item_id' => '32101060162673',
        'delivery_mode_32101060162673' => 'print',
        'pick_up' => 'PH',
        'user_supplied_enum' => 'Vol. 1, Γεωθερμία',
        'mfhd' => '221128922520006421'
      }
    end

    let(:valid_edd_item) do
      {
        'selected' => 'true',
        'type' => 'recap_marquand',
        'item_id' => '32101060221688',
        'delivery_mode_32101060221688' => 'edd',
        'edd_art_title' => 'Φιλοσοφία των Μαθηματικών',
        'mfhd' => '221128922510006421'
      }
    end

    let(:items) { [valid_print_item] }

    describe '#validate' do
      it 'adds no errors for a valid recap_marquand request' do
        validator.validate(record)
        expect(record.errors[:items]).to be_empty
      end

      it 'routes the item to validate_offsite rather than the else error "choose a request method"' do
        validator.validate(record)
        errors_text = record.errors[:items].map { |e| e.is_a?(String) ? e : e.to_s }.join(' ')
        expect(errors_text).not_to include('Please choose a Request Method')
      end

      it 'adds no errors when the valid item is an edd-delivery recap_marquand request' do
        allow(record).to receive(:items).and_return([valid_edd_item])
        validator.validate(record)
        expect(record.errors[:items]).to be_empty
      end
    end

    describe '#validate_selected' do
      it 'routes a print-delivery recap_marquand item to validate_offsite without error' do
        expect do
          validator.send(:validate_selected, record, valid_print_item)
        end.not_to(change { record.errors[:items].size })
      end

      it 'routes an edd-delivery recap_marquand item to validate_offsite without error' do
        expect do
          validator.send(:validate_selected, record, valid_edd_item)
        end.not_to(change { record.errors[:items].size })
      end
    end

    describe '#validate_user_supplied_enum_for_print' do
      it 'does not add an error when a print recap_marquand item has a user_supplied_enum' do
        expect do
          validator.send(:validate_user_supplied_enum_for_print, record, valid_print_item)
        end.not_to(change { record.errors[:items].size })
      end

      it 'adds an error when a print recap_marquand item does not have the user_supplied_enum' do
        item = valid_print_item.merge('user_supplied_enum' => '')
        expect do
          validator.send(:validate_user_supplied_enum_for_print, record, item)
        end.to change { record.errors[:items].size }.by(1)
        expect(record.errors[:items]).to include('Please specify the volume/part/issue information for your request.')
      end
    end
  end
end

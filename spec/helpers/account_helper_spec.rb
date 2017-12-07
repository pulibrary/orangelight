require 'rails_helper'
require './lib/orangelight/voyager_account.rb'

RSpec.describe ApplicationHelper do
  let(:account_data) { VoyagerAccount.new(fixture('/account_with_block_fines_recall.xml')) }
  let(:item_status_to_label) { helper.item_status_to_label(account_data.charged_items[0]) }
  let(:format_date) { helper.format_date(account_data.charged_items[0]['dueDate']) }
  let(:format_block_statement) { helper.format_block_statement(account_data.borrowing_blocks[0]['blockReason']) }
  let(:format_renew_string) { helper.format_renew_string(account_data.charged_items[0]) }
  let(:format_hold_cancel) { helper.format_hold_cancel(account_data.request_items[0]) }
  let(:display_account_balance) { helper.display_account_balance(account_data.fines_fees.last) }

  describe '#item_status_to_label' do
    it 'returns a label when given a numeric item status' do
      expect(item_status_to_label).to eq('Overdue/Recalled')
    end
  end

  describe '#format_date' do
    it 'returns a human-readable due date string' do
      expect(format_date).to eq('January 25 2016 at 11:45 PM')
    end
  end

  describe '#format_block_statement' do
    it 'returns a formatted string when an overdue block is in place' do
      expect(format_block_statement).to eq(I18n.t('blacklight.account.overdue_block'))
    end
  end

  describe '#format_renew_string' do
    it 'formats a string representing an item id to renew' do
      # just the item id for now
      expect(format_renew_string).to eq('7247566')
    end
  end

  describe '#format_hold_cancel' do
    it 'returns a formatted string for a hold request that can be cancelled' do
      expect(format_hold_cancel).to eq('item-3688389:holdrecall-587475:type-R')
    end
  end

  describe '#display_account_balance' do
    it 'returns a formatted account balance' do
      expect(display_account_balance).to eq('664.00 USD')
    end
  end
end

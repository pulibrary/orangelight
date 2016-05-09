require 'rails_helper'
require './lib/orangelight/voyager_account.rb'

RSpec.describe VoyagerAccount do
  let(:subject) { described_class.new(fixture('/pul_voyager_account_response.xml')) }
  let(:subject_with_fines_requests) { described_class.new(fixture('/generic_voyager_account_response.xml')) }
  let(:subject_with_lost_fines) { described_class.new(fixture('/account_with_block_fines_recall.xml')) }
  let(:subject_empty_account) { described_class.new(fixture('/generic_voyager_account_empty_response.xml')) }
  let(:subject_failed_renewal_charged_items) { described_class.new(fixture('/request_response_cannot_renew_short_term.xml')) }
  let(:subject_successful_renewal) { described_class.new(fixture('/successful_voyager_renew_response.xml')) }
  let(:subject_with_only_avail_items) { described_class.new(fixture('/generic_voyager_account_only_avail_items.xml')) }
  let(:subject_with_only_request_items) { described_class.new(fixture('/generic_voyager_account_only_request_items.xml')) }

  describe "#expiration_date" do
    it "Contains a Valid Expiration Date" do
      expect(subject.expiration_date).to match(/^\d\d\d\d-\d\d-\d\d\s.+/)
    end

    it "returns nil when expiration date is empty" do
      expect(subject_with_fines_requests.expiration_date).to be_nil
    end
  end

  describe "#borrowing_blocks" do
    it "Lists borrowing blocks active on an account" do
      expect(subject_with_lost_fines.borrowing_blocks.size).to eq(1)
    end

    it "returns nil when there are no borrowing blocks" do
      expect(subject_empty_account.borrowing_blocks).to be_nil
    end
  end

  describe "#has_blocks?" do
    it "returns true when an account has active blocks" do
      expect(subject_with_lost_fines.has_blocks?).to be_truthy
    end

    it "returns false when an account does not have active blocks" do
      expect(subject_empty_account.has_blocks?).to be_falsey
    end
  end

  describe "#failed_renewals?" do
    it "returns true when an account has failed renewal attempts" do
      expect(subject_failed_renewal_charged_items.failed_renewals?).to be_truthy
    end

    it "returns false when an account does not have have failed renewal attempts" do
      expect(subject_successful_renewal.failed_renewals?).to be_falsey
    end
  end

  describe "#fines_fees" do
    it "Lists fines and fees open on an account" do
      expect(subject_with_lost_fines.fines_fees.size).to eq(3)
    end

    it "returns nil when there are no fines or fees" do
      expect(subject_empty_account.fines_fees).to be_nil
    end
  end

  describe "#demerits" do
    it "Lists demerits open on an account" do
      expect(subject_with_fines_requests.demerits.size).to eq(5)
    end

    it "returns nil when there are no demerits" do
      expect(subject_empty_account.demerits).to be_nil
    end
  end

  describe "#charged_items" do
    it "Contains a list of the account's current charged items" do
      expect(subject.charged_items.size).to eq(5)
    end

    it "Includes a due date for each Charged Item" do
      subject.charged_items.each do |item|
        expect(item.key?("dueDate")).to eq(true)
      end
    end

    it "Notes if items can be renewed" do
      subject.charged_items.each do |item|
        expect(item.key?("renewable")).to eq(true)
      end
    end

    it "Returns nil when charged items are not present" do
      expect(subject_empty_account.charged_items).to be_nil
    end

    it "Includes messages attached to an item" do
      expect(subject_failed_renewal_charged_items.charged_items.is_a? Array).to be true
      expect(subject_failed_renewal_charged_items.charged_items.size).to eq(3)
      failed_renewal = subject_failed_renewal_charged_items.charged_items[0]
      expect(failed_renewal[:messages]["message"]).to eq('Item not authorized for renewal.')
    end

    it "Includes Renew Status When attached to an item" do
      expect(subject_failed_renewal_charged_items.charged_items.is_a? Array).to be true
      expect(subject_failed_renewal_charged_items.charged_items.size).to eq(3)
      failed_renewal = subject_failed_renewal_charged_items.charged_items[0]
      expect(failed_renewal[:renew_status]).to be_truthy
      expect(failed_renewal[:renew_status]["status"]).to eq('Not Renewed')
      expect(failed_renewal[:renew_status][:item_blocks]).to be_truthy
      expect(failed_renewal[:renew_status][:item_blocks]["blockDisplayName"]).to eq('Item not authorized for renewal.')
    end
  end

  describe "#avail_items" do
    it "Displays a list of available pickup items" do
      expect(subject_with_fines_requests.avail_items.size).to eq(1)
    end

    it "returns nil when no items are available for pickup" do
      expect(subject_empty_account.avail_items).to be_nil
    end

    it "Includes an expiration date for each active requests" do
      subject_with_fines_requests.avail_items.each do |avail_item|
        expect(avail_item.key?("expireDate")).to eq(true)
      end
    end

    it "Includes a Pickup Location" do
      subject_with_fines_requests.avail_items.each do |avail_item|
        expect(avail_item.key?("pickuplocation")).to eq(true)
      end
    end
  end

  describe "#request_items" do
    it "Is empty when the account does not have any active requests" do
      expect(subject_empty_account.request_items).to be_nil
    end

    it "Lists active requests for account when they are present" do
      expect(subject_with_fines_requests.request_items.size).to eq(3)
    end

    it "Includes an expiration date for each active requests" do
      subject_with_fines_requests.request_items.each do |request_item|
        expect(request_item.key?("expireDate")).to eq(true)
      end
    end

    it "Includes a Pickup Location" do
      subject_with_fines_requests.request_items.each do |request_item|
        expect(request_item.key?("pickuplocation")).to eq(true)
      end
    end
  end

  describe "#outstanding_hold_requests" do
    it "returns the total number of outstanding holds" do
      expect(subject_with_fines_requests.outstanding_hold_requests).to eq(4)
    end

    it 'returns the total number of holds when available items is empty' do
      expect(subject_with_only_request_items.outstanding_hold_requests).to eq(3)
    end

    it 'returns the total number of holds when request items is empty' do
      expect(subject_with_only_avail_items.outstanding_hold_requests).to eq(1)
    end
  end
end

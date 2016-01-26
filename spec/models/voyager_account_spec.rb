require 'rails_helper'

RSpec.describe VoyagerAccount do
  
  let(:subject) { VoyagerAccount.new(fixture('/pul_voyager_account_response.xml')) }
  let(:subject_with_fines_requests) { VoyagerAccount.new(fixture('/generic_voyager_account_response.xml')) }
  let(:subject_with_lost_fines) { VoyagerAccount.new(fixture('/account_with_block_fines_recall.xml')) }
  let(:subject_empty_account) { VoyagerAccount.new(fixture('/generic_voyager_account_empty_response.xml')) }

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
      expect(subject_with_fines_requests.borrowing_blocks.size).to eq(2)
    end

    it "returns nil when there are no borrowing blocks" do
      expect(subject_empty_account.borrowing_blocks).to be_nil
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
        expect(item.has_key?("dueDate")).to eq(true)
      end
    end

    it "Notes if items can be renewed" do
      subject.charged_items.each do |item|
        expect(item.has_key?("renewable")).to eq(true)
      end
    end

    it "Returns nil when charged items are not present" do
      expect(subject_empty_account.charged_items).to be_nil
    end

  end

  describe "#avail_items" do

    it "Displays a list of available pickup items" do
      #Confirm the data structure Ex Libris uses for items waiting for pickup
    end

    it "returns nil when no items are available for pickup" do
      expect(subject_empty_account.avail_items).to be_nil
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
      subject_with_fines_requests.request_items.each do |request|
        expect(request.has_key?("expireDate")).to eq(true)\
      end
    end
  end

end
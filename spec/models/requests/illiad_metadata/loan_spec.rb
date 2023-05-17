# frozen_string_literal: true
require 'rails_helper'

RSpec.describe(Requests::IlliadMetadata::Loan) do
  describe 'attributes' do
    it 'gets the LoanAuthor from the bib author' do
      loan = described_class.new(bib: { 'author' => 'Albert Einstein' }, patron: Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)), item: {})
      expect(loan.attributes['LoanAuthor']).to eq('Albert Einstein')
    end
    it 'gets the LoanDate from the bib date' do
      loan = described_class.new(bib: { 'date' => '1992' }, patron: Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)), item: {})
      expect(loan.attributes['LoanDate']).to eq('1992')
    end
  end
end

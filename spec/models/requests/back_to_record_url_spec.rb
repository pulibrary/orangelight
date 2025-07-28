# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::BackToRecordUrl do
  it 'goes to the desired catalog record' do
    params = ActionController::Parameters.new(system_id: 'SCSB-1234')
    expect(described_class.new(params).to_s).to eq '/catalog/SCSB-1234'
  end

  it 'includes open_holdings if provided' do
    params = ActionController::Parameters.new(system_id: 'SCSB-1234', open_holdings: 'Firestone Library - Stacks')
    expect(described_class.new(params).to_s).to eq '/catalog/SCSB-1234?open_holdings=Firestone+Library+-+Stacks'
  end

  it 'does not include irrelevant params' do
    params = ActionController::Parameters.new(system_id: 'SCSB-1234', dogs: 'Malamute')
    expect(described_class.new(params).to_s).to eq '/catalog/SCSB-1234'
  end
end

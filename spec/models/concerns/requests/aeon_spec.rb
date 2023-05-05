# frozen_string_literal: true
require 'rails_helper'

class ObjectWithAeon
  include Requests::Aeon
  def bib
    { id: 1234 }
  end

  def holding
    { "22740186070006421" => { "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421" }] } }
  end
end

describe Requests::Aeon do
  subject { ObjectWithAeon.new }
  let(:location) do
    { "code" => "rare$xc", "aeon_location" => true, "library" => { "code" => "rare" }, "holding_library" => { "code" => "rare" } }
  end
  before do
    allow(subject).to receive(:location).and_return(location)
  end
  describe '#aeon_basic_params' do
    it 'takes its ReferenceNumber from the bib MMS ID' do
      expect(subject.aeon_basic_params[:ReferenceNumber]).to eq(1234)
    end
  end
end

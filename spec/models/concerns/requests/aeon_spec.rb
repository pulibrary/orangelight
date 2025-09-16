# frozen_string_literal: true
require 'rails_helper'

class ObjectWithAeon
  include Requests::Aeon

  def bib
    { id: 1234 }
  end

  def holding
    Requests::Holding.new mfhd_id: "22740186070006421", holding_data: { "sub_location" => ["Euro 20Q"], "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421" }] }
  end
end

class ObjectWithAeonAndAccessRestrictions < ObjectWithAeon
  def bib
    { id: 1234, access_restrictions_note_display: ["For conservation reasons, access is granted for compelling reasons only."] }
  end
end

describe Requests::Aeon, requests: true do
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

    it 'takes its SubLocation from the holdings_1display' do
      expect(subject.aeon_basic_params[:SubLocation]).to eq('Euro 20Q')
    end

    it 'uses a default text for ItemInfo1' do
      expect(subject.aeon_basic_params[:ItemInfo1]).to eq('Reading Room Access Only')
    end
  end

  context 'when document has access restrictions' do
    subject { ObjectWithAeonAndAccessRestrictions.new }
    it 'takes ItemInfo1 from access restrictions' do
      expect(subject.aeon_basic_params[:ItemInfo1]).to eq('For conservation reasons, access is granted for compelling reasons only.')
    end
  end
end

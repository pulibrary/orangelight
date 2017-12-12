require 'rails_helper'

RSpec.describe HoldingLocations do
  describe '#load' do
    subject { described_class.load }

    let(:response) { instance_double(Faraday::Response, status: status, body: body) }
    let(:status) { 200 }
    let(:body) { '[{"label":"African American Studies Reading Room","code":"aas","library":{"label":"Firestone Library","code":"firestone","order":1}}]' }

    before { allow(Faraday).to receive(:get).and_return(response) }
    context 'with a successful response from bibdata' do
      it 'returns the holdings location hash' do
        expect(subject).to include('aas')
      end
    end

    context 'with an unsuccessful response from bibdata' do
      let(:status) { 500 }

      it 'returns an empty hash' do
        expect(subject).to be_empty
      end
    end
  end
end

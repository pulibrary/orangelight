require 'rails_helper'

describe HighVoltage::PagesController, type: :controller do
  %w[help about].each do |page|
    context "on GET to /#{page}" do
      before do
        get :show, params: { id: page }
      end
      it 'succeeds' do
        expect(response).to have_http_status(200)
      end
      it { is_expected.to render_template(page) }
    end
  end
end

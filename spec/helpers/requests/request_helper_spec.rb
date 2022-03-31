require 'rails_helper'

RSpec.describe Requests::RequestHelper, type: :helper do
  describe '#request_title' do
    it 'returns a trace form title when mode is set' do
      assign(:mode, "trace") # instance variable
      expect(helper.request_title).to eq(I18n.t('requests.trace.form_title'))
    end

    it 'returns the default form title' do
      expect(helper.request_title).to eq(I18n.t('requests.default.form_title'))
    end
  end
end

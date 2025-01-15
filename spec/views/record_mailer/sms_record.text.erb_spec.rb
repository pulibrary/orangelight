# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'record_mailer/sms_record' do
  it 'includes the call number if the solr document has one' do
    assign(:documents, [SolrDocument.new({ id: '123', call_number_display: ['ABC 456'] })])
    assign(:url_gen_params, {})
    render

    expect(rendered).to have_text('Call number: ABC 456')
  end
  it 'does not include the call number if there is not one in the solr document' do
    assign(:documents, [SolrDocument.new({ id: '123' })])
    assign(:url_gen_params, {})
    render

    expect(rendered).not_to have_text('Call number')
  end
end

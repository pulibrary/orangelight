# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'Content Security Policy' do
  let(:directives) do
    get '/'
    response.headers['content-security-policy-report-only'].split(';').map(&:strip)
  end
  it 'allows libwizard to embed the catalog in an iframe' do
    frame_ancestors_directive = directives.find { |directive| directive.start_with? 'frame-ancestors' }
    expect(frame_ancestors_directive).to include('https://princeton.libwizard.com')
  end
  it 'allows the catalog to embed figgy in an iframe' do
    frame_src_directive = directives.find { |directive| directive.start_with? 'frame-src' }
    expect(frame_src_directive).to include('https://figgy.princeton.edu')
  end
end

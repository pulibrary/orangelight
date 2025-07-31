# frozen_string_literal: true

require 'rails_helper'

describe Orangelight::Middleware::NoFileUploads, type: :request do
  it 'does not create a tempfile when the user does a multipart/form-data request' do
    allow(Tempfile).to receive(:new).and_call_original
    mock_upload = Rack::Test::UploadedFile.new(
      StringIO.new("<?php echo 'codeb0ss:'; echo '<pre>' . shell_exec($_GET['cmd']) . '</pre>'; ?>"),
      'Application/php',
      false, # not a binary file
      original_filename: 'bad.php'
    )

    expect do
      post '/feedback', params: { feedback_form: { name: mock_upload } }, headers: { 'Content-Type' => 'multipart/form-data' }
    end.to raise_error 'Sorry, the catalog does not support file uploads'

    expect(Tempfile).not_to have_received(:new)
  end
end

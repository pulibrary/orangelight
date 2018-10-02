# frozen_string_literal: true

require 'rails_helper'

describe Orangelight::Middleware::InvalidParameterHandler do
  describe '#call' do
    subject(:invalid_parameter_handler) { described_class.new(app) }

    let(:app) { instance_double(Rails::Application) }
    let(:query_string) do
      'f%5Blocation%5D%5B%5D=Mudd%2BManuscript%2BLibrary'
    end
    let(:env) do
      {
        'REQUEST_METHOD' => 'GET',
        'QUERY_STRING' => query_string,
        'REQUEST_URI' => "/catalog?#{query_string}",
        'PATH_INFO' => '/',
        'HTTP_ACCEPT' => 'application/json',
        'rack.input' => ''
      }
    end

    it 'delegates the response to the app' do
      allow(app).to receive(:call)
      invalid_parameter_handler.call(env)

      expect(app).to have_received(:call).with(env)
    end

    context 'when the HTTP request contains invalid parameters' do
      let(:query_string) do
        'f%5Blocation%5D%5B%5D=Mudd%2BManuscript%2BLibrary&%2B%2B%2'
      end

      before do
        allow(Rails.logger).to receive(:error)
      end

      it 'returns a 400 response and logs an error' do
        status, headers, body = invalid_parameter_handler.call(env)

        expect(body.join).to eq('Bad Request')
        expect(status).to eq(400)
        expect(headers['Content-Type']).to eq('application/json; charset=UTF-8')
        expect(headers['Content-Length']).to eq('11')
        expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request\: Invalid query parameters\: invalid %\-encoding \(%2B%2B%2\) within the environment/)
      end
    end
  end
end

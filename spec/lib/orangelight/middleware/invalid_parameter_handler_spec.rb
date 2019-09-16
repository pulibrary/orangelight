# frozen_string_literal: true

require 'rails_helper'

describe Orangelight::Middleware::InvalidParameterHandler do
  describe '#call' do
    subject(:invalid_parameter_handler) { described_class.new(app) }

    let(:app) { Rails.application }
    let(:query_string) do
      'f%5Blocation%5D%5B%5D=Mudd%2BManuscript%2BLibrary'
    end
    let(:env) do
      {
        'REQUEST_METHOD' => 'GET',
        'QUERY_STRING' => query_string,
        'REQUEST_URI' => "/catalog?#{query_string}",
        'PATH_INFO' => '/',
        'HTTP_ACCEPT' => 'text/html',
        'rack.input' => ''
      }
    end

    it 'delegates the response to the app' do
      allow(app).to receive(:call)
      invalid_parameter_handler.call(env)

      expect(app).to have_received(:call).with(env)
    end

    context 'with a JSON request' do
      let(:env) do
        {
          'REQUEST_METHOD' => 'GET',
          'QUERY_STRING' => query_string,
          'REQUEST_URI' => "/catalog.json?#{query_string}",
          'PATH_INFO' => '/',
          'HTTP_ACCEPT' => 'application/json',
          'rack.input' => ''
        }
      end

      it 'delegates the response to the app' do
        allow(app).to receive(:call).and_call_original
        output = invalid_parameter_handler.call(env)

        expect(app).to have_received(:call).with(env)

        body = output.last
        body_content = body.first
        expect { JSON.parse(body_content) }.not_to raise_error(JSON::ParserError)
        json_response = JSON.parse(body_content)

        expect(json_response).to include('data')
        expect(json_response).to include('included')
      end
    end

    context 'when the HTTP request contains invalid parameters' do
      let(:query_string) do
        'f%5Blocation%5D%5B%5D=Mudd%2BManuscript%2BLibrary&%2B%2B%2'
      end

      before do
        allow(Rails.logger).to receive(:error)
      end

      it 'returns a 400 response, displays an error message, and logs the error' do
        status, headers, body = invalid_parameter_handler.call(env)

        expect(body.join).to include('For help, please email', 'start over')
        expect(status).to eq(400)
        expect(headers['Content-Type']).to eq('text/html; charset=UTF-8')
        expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request\: Invalid query parameters\: invalid %\-encoding \(%2B%2B%2\) within the environment/)
      end
    end

    context 'when the HTTP request contains an nil facet values list' do
      let(:query_string) do
        'f%5Bformat%5D%5B'
      end

      before do
        allow(Rails.logger).to receive(:error)
      end

      it 'returns a 400 response, displays an error message, and logs the error' do
        status, headers, body = invalid_parameter_handler.call(env)

        expect(body.join).to include('For help, please email', 'start over')
        expect(status).to eq(400)
        expect(headers['Content-Type']).to eq('text/html; charset=UTF-8')
        expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request\: Facet field \[format\]\[ has a nil value within the environment nil/)
      end
    end

    context 'when the HTTP request contains ' do
      let(:query_string) do
        'f%5Blocation%5D%5B%5D=Mudd%2BManuscript%2BLibrary&%2B%2B%2'
      end

      before do
        allow(Rails.logger).to receive(:error)
      end

      it 'returns a 400 response, displays an error message, and logs the error' do
        status, headers, body = invalid_parameter_handler.call(env)

        expect(body.join).to include('For help, please email', 'start over')
        expect(status).to eq(400)
        expect(headers['Content-Type']).to eq('text/html; charset=UTF-8')
        expect(Rails.logger).to have_received(:error).with(/Invalid parameters passed in the request\: Invalid query parameters\: invalid %\-encoding \(%2B%2B%2\) within the environment/)
      end
    end
  end
end

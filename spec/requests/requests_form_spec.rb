# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Request Form Submission', type: :request do
  let(:user) { create(:user) }
  let(:patron) { build(:patron, user: user) }

  before do
    sign_in user
    allow(Requests::Patron).to receive(:new).and_return(patron)
  end

  describe 'POST /requests/submit' do
    context 'with valid submission data' do
      let(:valid_params) do
        {
          requestable: [
            {
              'user_name' => 'Test User',
              'email' => 'test@example.com',
              'selected' => 'true',
              'delivery_type' => 'print'
            }
          ],
          bib: {
            id: 'test123',
            title: 'Test Book'
          }
        }
      end

      it 'returns success JSON response' do
        submission = instance_double(Requests::Submission)
        allow(Requests::Submission).to receive(:new).and_return(submission)
        allow(submission).to receive(:valid?).and_return(true)
        allow(submission).to receive(:process_submission).and_return([])
        allow(submission).to receive(:service_errors).and_return([])
        allow(submission).to receive(:success_messages).and_return(['Request submitted successfully'])
        allow(submission).to receive(:errors).and_return(instance_double(ActiveModel::Errors, empty?: true))
        allow(submission).to receive(:id).and_return('test123')

        post '/requests/submit', params: valid_params, headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:success)

        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['message']).to include('Request submitted successfully')
        expect(json_response).to have_key('flash_messages_html')
      end
    end

    context 'with validation errors' do
      let(:invalid_params) do
        {
          requestable: [
            {
              'user_name' => '',
              'email' => 'invalid-email',
              'selected' => 'true',
              'delivery_type' => 'digitization'
              # Missing title for digitization request
            }
          ],
          bib: {
            id: 'test123',
            title: 'Test Book'
          }
        }
      end

      it 'returns error JSON response with validation errors' do
        submission = instance_double(Requests::Submission)
        error_messages = {
          title: ['Please specify title for the selection you want digitized.'],
          items: [
            {
              'item123' => {
                'type' => 'digitization',
                'text' => 'Please specify title for the selection you want digitized.'
              }
            }
          ]
        }

        allow(Requests::Submission).to receive(:new).and_return(submission)
        allow(submission).to receive(:valid?).and_return(false)
        allow(submission).to receive(:errors).and_return(
          instance_double(ActiveModel::Errors, messages: error_messages, empty?: false)
        )

        post '/requests/submit', params: invalid_params, headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:success)

        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['errors']).to be_present
        expect(json_response['errors']['title']).to include('Please specify title for the selection you want digitized.')
        expect(json_response).to have_key('flash_messages_html')
      end
    end

    context 'with service errors' do
      let(:valid_params_with_service_error) do
        {
          requestable: [
            {
              'user_name' => 'Test User',
              'email' => 'test@example.com',
              'selected' => 'true',
              'delivery_type' => 'digitization'
            }
          ],
          bib: {
            id: 'test123',
            title: 'Test Book'
          }
        }
      end

      it 'returns error JSON response with service errors' do
        # Mock submission that's valid but fails at service level
        submission = instance_double(Requests::Submission)
        service_error = instance_double(Requests::Submissions::Service,
                                        errors: [{ type: 'digitize', error: 'Digitization service unavailable' }],
                                        error_hash: { digitization: 'Service error occurred' })
        allow(Requests::RequestMailer).to receive(:send).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

        allow(Requests::Submission).to receive(:new).and_return(submission)
        allow(submission).to receive(:valid?).and_return(true)
        allow(submission).to receive(:process_submission).and_return([service_error])
        allow(submission).to receive(:service_errors).and_return(['Service error'])
        allow(submission).to receive(:errors).and_return(instance_double(ActiveModel::Errors, empty?: true))
        allow(submission).to receive(:id).and_return('test123')
        allow(submission).to receive(:to_h).and_return({
                                                         'patron' => {
                                                           'netid' => 'test123',
                                                           'email' => 'test@example.com'
                                                         }
                                                       })

        post '/requests/submit', params: valid_params_with_service_error, headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:success)

        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['errors']).to be_present
        expect(json_response).to have_key('flash_messages_html')
      end
    end
  end

  describe 'Error message formatting' do
    let(:controller) { Requests::FormController.new }

    describe '#format_validation_errors' do
      it 'formats regular field errors' do
        error_messages = {
          email: ['Invalid email format'],
          name: ['Name is required']
        }

        result = controller.send(:format_validation_errors, error_messages)

        expect(result[:email]).to eq(['Invalid email format'])
        expect(result[:name]).to eq(['Name is required'])
      end

      it 'formats items field errors specially' do
        error_messages = {
          items: [
            {
              'item123' => {
                'type' => 'digitization',
                'text' => 'Please specify title for the selection you want digitized.'
              }
            }
          ]
        }

        result = controller.send(:format_validation_errors, error_messages)

        expect(result[:items]).to be_an(Array)
        expect(result[:items].first).to include(
          key: 'item123',
          type: 'digitization',
          text: 'Please specify title for the selection you want digitized.'
        )
      end

      it 'handles simple string items errors' do
        error_messages = {
          items: ['No items selected']
        }

        result = controller.send(:format_validation_errors, error_messages)

        expect(result[:items].first).to include(text: 'No items selected')
      end
    end
  end
end

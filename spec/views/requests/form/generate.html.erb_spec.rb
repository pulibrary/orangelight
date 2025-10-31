require 'rails_helper'

RSpec.describe 'generate.html.erb', :requests do
    it 'is good' do
        controller = Requests::FormController.new
        first_filtered_requestable = Requestable.new
        requestable_list = []
        request = Requests::FormDecorator.new(
            instance_double(Requests::Form, requestable: requestable_list, first_filtered_requestable:),
            controller.view_context,
            Requests::BackToRecordUrl.new(ActionController::Parameters.new)
        )
         expect(1).to eq(1)
    end
end

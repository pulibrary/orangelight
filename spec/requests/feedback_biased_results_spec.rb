# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "biased results feedback", type: :request do
  describe "going to the biased results form" do
    it "is successful" do 
      get "/feedback/biased_results", params:{
        report_biased_results_form: {
          q: "cats"
        }  
      }  
      expect(response).to be_successful
    end
  end
end


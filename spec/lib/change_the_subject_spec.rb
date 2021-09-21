# frozen_string_literal: true

require 'rails_helper'

##
# When our catalog records contain outdated subject headings, we need the ability
# to update them at index time to preferred terms.
RSpec.describe ChangeTheSubject do
  let(:response) { described_class.check(subject_term) }

  context "a replaced term" do
    let(:subject_term) { "Illegal Aliens" }

    it "suggests a replacement" do
      expect(response[:replacement]).to eq "Undocumented Immigrants"
    end

    it "gives a reason" do
      expect(response[:rationale]).to match(/LoC proposed as replacements/)
    end
  end

  context "a term that has not been replaced" do
    let(:subject_term) { "Daffodils" }

    it "returns nil" do
      expect(response).to be_nil
    end
  end
end

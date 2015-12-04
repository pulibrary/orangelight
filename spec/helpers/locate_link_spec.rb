require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#locate_link helpers" do

    let(:stackmap_location) { "f" }
    let(:stackmap_ineligible_location) { "annexa" }
    let(:bib) { "123456" }
    let(:stackmap_library) { "Firestone"}
    let(:stackmap_ineligible_library) { "Fine Annex" }

    it "Returns a Stackmap Link for a Mapping Location" do
      stackmap_link = locate_link(stackmap_location, bib, stackmap_library)
      expect(stackmap_link).to be_truthy
      expect(stackmap_link).to include("#{ENV['stackmap_base']}?loc=#{stackmap_location}&amp;id=#{bib}")

    end

    it "Does not return a stackmap link for an inaccessible location" do
      stackmap_link = locate_link(stackmap_ineligible_location, bib, stackmap_ineligible_library)
      expect(stackmap_link).to eq("")
    end

  end

end
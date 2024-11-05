# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::ElectronicAccessPlainTextPresenter do
  describe '#values' do
    it 'is formatted nicely' do
      document = SolrDocument.new({
                                    electronic_access_1display: '{"http://arks.princeton.edu/ark:/88435/dsp01zk51vk08g":' \
                                                                '["DataSpace","Full text"]}'
                                  })
      field_config = Blacklight::Configuration::Field.new(label: 'Online access', field: 'electronic_access_1display')
      # rubocop:disable RSpec/VerifiedDoubles
      view_context = double('View context', should_render_field?: true)
      # rubocop:enable RSpec/VerifiedDoubles
      presenter = described_class.new(view_context, document, field_config)

      expect(presenter.values).to eq ["\tFull text - DataSpace: http://arks.princeton.edu/ark:/88435/dsp01zk51vk08g"]
    end
  end
end

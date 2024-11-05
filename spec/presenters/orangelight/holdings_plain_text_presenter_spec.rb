# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::HoldingsPlainTextPresenter do
  describe '#values' do
    it 'is formatted nicely' do
      document = SolrDocument.new({
                                    holdings_1display: '{"9034559":{"location":"Remote Storage","library":"ReCAP","location_code":"recap$pa",' \
                                                       '"call_number":"DT194 .A439 2016","call_number_browse":"DT194 .A439 2016",' \
                                                       '"location_has":["Juzʼ 1-juzʼ 2"]}}'
                                  })
      field_config = Blacklight::Configuration::Field.new(label: 'Holdings', field: 'holdings_1display')
      # rubocop:disable RSpec/VerifiedDoubles
      view_context = double('View context', should_render_field?: true)
      # rubocop:enable RSpec/VerifiedDoubles
      presenter = described_class.new(view_context, document, field_config)

      expect(presenter.values).to include "\n\tLocation: ReCAP - Remote Storage\n\tCall number: DT194 .A439 2016"
    end
  end
end

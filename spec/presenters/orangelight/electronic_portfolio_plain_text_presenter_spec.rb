# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::ElectronicPortfolioPlainTextPresenter do
  describe '#values' do
    it 'is formatted nicely' do
      document = SolrDocument.new({
                                    electronic_portfolio_s: [
                                      '{"desc":null,"title":"Full Text","url":"https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53827030770006421&Force_direct=true","start":null,"end":"latest"}',
                                      '{"desc":null,"title":"Second Title","url":"https://example.com","start":null,"end":"latest"}'
                                    ]
                                  })
      field_config = Blacklight::Configuration::Field.new(label: 'Online access', field: 'electronic_portfolio_s')
      # rubocop:disable RSpec/VerifiedDoubles
      view_context = double('View context', should_render_field?: true)
      # rubocop:enable RSpec/VerifiedDoubles
      presenter = described_class.new(view_context, document, field_config)
      expect(presenter.values[0]).to eq("\tFull Text: https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53827030770006421&Force_direct=true\n")
      expect(presenter.values[1]).to eq("\tSecond Title: https://example.com\n")
    end
  end
end

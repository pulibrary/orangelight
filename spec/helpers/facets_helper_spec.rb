# frozen_string_literal: true

require 'rails_helper'

describe FacetsHelper do
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#render_facet_partials' do
    let(:facet_names) do
      %w[
        access_facet
        location
      ]
    end
    let(:response) { instance_double(Blacklight::Solr::Response) }
    let(:access_facet_field) { instance_double(Blacklight::Solr::Response::Facets::FacetField) }
    let(:access_facet_item) do
      instance_double(Blacklight::Solr::Response::Facets::FacetItem)
    end
    let(:location_facet_field) { instance_double(Blacklight::Solr::Response::Facets::FacetField) }
    let(:location_facet_item) { instance_double(Blacklight::Solr::Response::Facets::FacetItem) }
    let(:aggregations) do
      {
        'access_facet' => access_facet_field,
        'location' => location_facet_field
      }
    end

    before do
      allow(helper).to receive(:render)
      allow(access_facet_field).to receive(:items).and_return([access_facet_item])
      allow(access_facet_field).to receive(:name).and_return('access_facet')
      allow(location_facet_field).to receive(:items).and_return([location_facet_item])
      allow(location_facet_field).to receive(:name).and_return('location')
      allow(response).to receive(:aggregations).and_return(aggregations)
      helper.instance_variable_set(:@response, response)
    end

    it 'renders the facet partials' do
      expect(helper.render_facet_partials(facet_names)).to eq('')
      expect(helper).to have_received(:render).twice
    end

    context 'when an error is encountered rendering the partials for the facets' do
      before do
        # Trigger an error
        helper.instance_variable_set(:@response, nil)
        allow(Rails.logger).to receive(:error)

        helper.render_facet_partials(facet_names)
      end

      it 'logs the error raised' do
        expect(Rails.logger).to have_received(:error).with(/Failed to render the facet partials for access_facet,location/)
      end

      context 'the method is invoked within the scope of a Controller' do
        before do
          allow(helper).to receive(:head)

          helper.render_facet_partials(facet_names)
        end

        it 'responds with a HEAD status (i. e. no body content)' do
          expect(helper).to have_received(:head)
        end
      end
    end
  end
end

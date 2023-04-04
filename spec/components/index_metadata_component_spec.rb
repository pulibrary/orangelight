# frozen_string_literal: true

require "rails_helper"

class MyTestingComponent < ViewComponent::Base
  def call
    'Rendering content from the component'
  end
end

RSpec.describe IndexMetadataComponent, type: :component do
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_index_field 'my_first_field'
      config.add_index_field 'my_second_field', show: true
      config.add_index_field 'do_not_show_this_field', show: false
    end
  end
  let(:component) do
    document = SolrDocument.new({
                                  'my_first_field': 'Hello',
                                  'my_second_field': ['Goodbye', 'Auf Wiedersehen'],
                                  'do_not_show_this_field': 'Behind the scenes'
                                })
    view_context = double(document_index_view_type: 'index')
    allow(view_context).to receive(:should_render_field?).and_return true
    presenter = Blacklight::IndexPresenter.new(document, view_context, blacklight_config)
    described_class.new presenter:
  end
  it 'renders an li for each valid field' do
    expect(render_inline(component).search('./li').length).to eq(2)
  end
  it 'renders the field value' do
    expect(render_inline(component).css('li').first.text.strip).to eq('Hello')
  end
  it 'renders multi-valued fields' do
    expect(render_inline(component).search('./li/ul/li').length).to eq(2)
    expect(render_inline(component).search('./li/ul/li').map(&:text).map(&:strip)).to eq(['Goodbye', 'Auf Wiedersehen'])
  end
  context 'when the index field is configured to use a component' do
    let(:blacklight_config) do
      Blacklight::Configuration.new.configure do |config|
        config.add_index_field 'my_first_field', component: MyTestingComponent
      end
    end
    it 'renders content from the component' do
      expect(render_inline(component).css('li').first.text.strip).to eq('Rendering content from the component')
    end
  end
end

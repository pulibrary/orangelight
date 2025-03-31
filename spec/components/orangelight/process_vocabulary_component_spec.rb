# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::ProcessVocabularyComponent, type: :component do
  let(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(field:)))
  end
  let(:document) do
    SolrDocument.new('lc_subject_display' => ["Immigrants—South Africa",
                                              "Immigrants—Housing—South Africa",
                                              "Immigrants—Services for—South Africa",
                                              "Christian sexual minorities—Africa",
                                              "Homophobia—Africa",
                                              "Transgender people—Africa",
                                              "Transgender men—Africa",
                                              "Lesbians—Africa",
                                              "Bisexuals—Africa",
                                              "Gays—Africa"])
  end
  let(:field_config) { Blacklight::Configuration::Field.new(key: 'field', field: 'lc_subject_display', label: 'Subject(s)') }

  let(:field) do
    Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config)
  end

  it 'renders the subject browse link' do
    lc_subject_display1 = "Immigrants—South Africa"

    expect(rendered).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape lc_subject_display1}")
  end

  it 'renders the search subject link' do
    lc_subject_display2 = "Immigrants"
    expect(rendered).to have_link('Immigrants', href: "/?f[subject_facet][]=#{CGI.escape lc_subject_display2}")
  end
end

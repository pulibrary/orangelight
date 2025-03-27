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
                                              "Gays—Africa"],
                     'aat_s': [
                       "fairy tales"
                     ])
  end

  describe 'it renders the library subject display field with' do
    let(:field_config) { Blacklight::Configuration::Field.new(key: 'lc_subject_display', field: 'lc_subject_display', label: 'Subject(s)') }
    let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }
    it 'browse link and vocabulary type Library of congress subjects' do
      lc_subject_display1 = "Immigrants—South Africa"
      expect(rendered).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape lc_subject_display1}&vocab=lc_subject_facet")
    end

    it 'search link to search on lc subject facet' do
      lc_subject_display2 = "Immigrants"
      expect(rendered).to have_link(href: "/?f[lc_subject_facet][]=#{CGI.escape lc_subject_display2}")
    end
  end
  describe 'it renders the aat_s field with' do
    let(:field_config) { Blacklight::Configuration::Field.new(key: 'aat_s', field: 'aat_s', label: 'Getty AAT genre') }
    let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }
    it 'browse link and vocabulary type Art & architecture thesaurus' do
      aat_s1 = "fairy tales"
      expect(rendered).to have_link('[Browse]', href: "/browse/subjects?q=#{CGI.escape aat_s1}&vocab=aat_genre_facet")
    end
    it 'search link to search on aat genre facet' do
      aat_s1 = "fairy tales"
      expect(rendered).to have_link(href: "/?f[aat_genre_facet][]=#{CGI.escape aat_s1}")
    end
  end
end

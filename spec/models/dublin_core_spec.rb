# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::DublinCore do
  subject(:document) { SolrDocument.new(properties) }

  let(:properties) do
    {
      'id' => '9618072',
      'author_roles_1display' => '{\"secondary_authors\":[],\"translators\":[],\"editors\":[],\"compilers\":[],\"primary_author\":\"Kim, Mu-bong\"}',
      'title_display' => "Yŏkchu pulsŏl amit'agyŏng ŏnhae pulchŏng simdaranigyŏng ŏnhae.",
      'title_vern_display' => '역주불설아미타경언해불정심다라니경언해',
      'title_citation_display' => [
        "Yŏkchu pulsŏl amit'agyŏng ŏnhae pulchŏng simdaranigyŏng ŏnhae",
        '역주불설아미타경언해불정심다라니경언해'
      ],
      'compiled_created_t' => [
        "Yŏkchu pulsŏl amit'agyŏng ŏnhae pulchŏng simdaranigyŏng ŏnhae.",
        '역주불설아미타경언해불정심다라니경언해'
      ],
      'pub_created_display' => [
        'Sŏul: Sejong Taewang Kinyŏm Saŏphoe, 2018.',
        '서울: (사)세종대왕기념사업회, 2018.'
      ],
      'pub_created_s' => [
        'Sŏul: Sejong Taewang Kinyŏm Saŏphoe, 2018.',
        '서울: (사)세종대왕기념사업회, 2018.'
      ],
      'pub_citation_display' => [
        'Sŏul: Sejong Taewang Kinyŏm Saŏphoe',
        '서울: (사)세종대왕기념사업회'
      ],
      'pub_date_display' => [
        '2018'
      ],
      'pub_date_start_sort' => 2018,
      'format' => [
        'Book'
      ],
      'description_display' => [
        '295 p.'
      ],
      'description_t' => [
        '295 p.'
      ],
      'language_facet' => [
        'Korean'
      ],
      'language_code_s' => [
        'kor'
      ],
      'isbn_display' => [
        '9788982757365'
      ],
      'isbn_s' => [
        '9788982757365'
      ]
    }
  end

  describe '#export_as_oai_dc_xml' do
    it 'returns DC fields wrapped in OAI XML' do
      expect(Nokogiri::XML(document.export_as_oai_dc_xml).xpath('/oai_dc:dc')).to be_truthy
      expect(document.to_semantic_values).to be_truthy
      document.to_semantic_values.each_key do |field|
        expect(Nokogiri::XML(document.export_as_rdf_dc).xpath("//dc:#{field}")).to be_truthy
      end
    end
  end

  describe '#export_as_rdf_dc' do
    it 'contains DC fields wrapped in RDF XML' do
      expect(Nokogiri::XML(document.export_as_rdf_dc).xpath('/rdf:RDF')).to be_truthy
      expect(document.to_semantic_values).to be_truthy
      document.to_semantic_values.each_key do |field|
        expect(Nokogiri::XML(document.export_as_rdf_dc).xpath("//dc:#{field}")).to be_truthy
      end
    end
  end
end

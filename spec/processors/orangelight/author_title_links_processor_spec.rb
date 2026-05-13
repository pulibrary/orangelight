# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::AuthorTitleLinksProcessor do
  it 'renders tags for each segment of the hierarchy' do
    processor = described_class.new(
      ["[[\"Beaumarchais, Pierre Augustin Caron de, 1732-1799.\",\"Barbier de Séville.\"]]"],
      Blacklight::Configuration::Field.new(author_title_links: true),
      SolrDocument.new,
      {},
      { context: 'show' },
      [Blacklight::Rendering::Terminator]
    )
    rendered = processor.render.map { Nokogiri::HTML.fragment(it) }
    expect(rendered.length).to eq 1
    links = rendered[0].css('a')
    expect(links.length).to eq 3
    expect(links.map(&:text)).to eq [
      'Beaumarchais, Pierre Augustin Caron de, 1732-1799.',
      'Barbier de Séville.',
      '[Browse]'
    ]
    expect(links.map { it.attr('href') }).to eq [
      '/?f[author_s][]=Beaumarchais%2C+Pierre+Augustin+Caron+de%2C+1732-1799',
      '/?f[name_title_browse_s][]=Beaumarchais%2C+Pierre+Augustin+Caron+de%2C+1732-1799.+Barbier+de+Se%CC%81ville',
      '/browse/name_titles?q=Beaumarchais%2C+Pierre+Augustin+Caron+de%2C+1732-1799.+Barbier+de+Se%CC%81ville.'
    ]
  end

  it 'can skip the author link and only render author/title links' do
    processor = described_class.new(
      ["[[\"Dawwānī, Muḥammad ibn Asʻad, 1426 or 1427-1512 or 1513.\",\"Works.\",\"Selections.\"]]"],
      Blacklight::Configuration::Field.new(author_title_links: true, no_author_link: true),
      SolrDocument.new,
      {},
      { context: 'show' },
      [Blacklight::Rendering::Terminator]
    )
    rendered = processor.render.map { Nokogiri::HTML.fragment(it) }
    expect(rendered.length).to eq 1
    links = rendered[0].css('a')
    expect(links.map(&:text)).to eq [
      'Works.',
      'Selections.',
      '[Browse]'
    ]
    expect(links.map { it.attr('href') }).to eq [
      '/?f[name_title_browse_s][]=Daww%C4%81n%C4%AB%2C+Mu%E1%B8%A5ammad+ibn+As%CA%BBad%2C+1426+or+1427-1512+or+1513.+Works',
      '/?f[name_title_browse_s][]=Daww%C4%81n%C4%AB%2C+Mu%E1%B8%A5ammad+ibn+As%CA%BBad%2C+1426+or+1427-1512+or+1513.+Works.+Selections',
      '/browse/name_titles?q=Daww%C4%81n%C4%AB%2C+Mu%E1%B8%A5ammad+ibn+As%CA%BBad%2C+1426+or+1427-1512+or+1513.+Works.+Selections.'
    ]
  end
end

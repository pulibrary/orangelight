require 'rsolr'
require 'json'

namespace :pulsearch do
  namespace :solr do
    desc 'Updates solr config files from github'
    task :update, :solr_dir do |_t, args|
      solr_dir = args[:solr_dir] || Rails.root.join('solr')

      ['mapping-ISOLatin1Accent.txt', 'protwords.txt', 'schema.xml', 'solrconfig.xml',
       'spellings.txt', 'stopwords.txt', 'stopwords_en.txt', 'synonyms.txt',
       'CJKFoldingFilter.jar', 'lucene-umich-solr-filters-6.0.0-SNAPSHOT.jar'].each do |file|
        response = Faraday.get url_for_file("conf/#{file}")
        File.open(File.join(solr_dir, 'conf', file), 'wb') { |f| f.write(response.body) }
      end
    end

    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      docs = JSON.parse(File.read('spec/fixtures/current_fixtures.json'))
      solr.add docs
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end

    desc 'Delete fixtures from Solr'
    task :deindex do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end
  end

  private

    def url_for_file(file)
      "https://raw.githubusercontent.com/pulibrary/pul_solr/master/solr_configs/orangelight/#{file}"
    end
end

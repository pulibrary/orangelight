# frozen_string_literal: true

require 'rsolr'
require 'json'
require Rails.root.join('app', 'services', 'robots_generator_service').to_s

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
      ['spec/fixtures/voyager', 'spec/fixtures/alma'].each do |dir|
        Dir["#{dir}/**/*.json"].each do |file_path|
          doc = JSON.parse(File.read(file_path))
          solr.add doc
          solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
        end
      end
    end

    desc 'Delete fixtures from Solr'
    task :deindex do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
      solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    end
  end

  desc 'Generate a robots.txt file'
  task :robots_txt do |_t, args|
    file_path = args[:file_path] || Rails.root.join('public', 'robots.txt')
    robots = RobotsGeneratorService.new(path: file_path, disallowed_paths: Rails.configuration.robots.disallowed_paths)
    robots.insert_group(user_agent: '*')
    robots.insert_crawl_delay(10)
    robots.insert_sitemap(Rails.configuration.robots.sitemap_url)
    robots.generate
    robots.write
  end

  private

    def url_for_file(file)
      "https://raw.githubusercontent.com/pulibrary/pul_solr/main/solr_configs/catalog-production-v2/#{file}"
    end
end

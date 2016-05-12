require 'rsolr'
require 'json'

namespace :pulsearch do
  namespace :solr do
    desc 'Copies solr config files to solr wrapper instance'
    task :config, :instance_dir do |t, args|
      instance_dir = args[:instance_dir]

      # copy cjk folding filter to solr directory
      cjk_from = Rails.root.join('solr', 'CJKFoldingFilter.jar')
      cjk_to = File.join(instance_dir,'contrib','analysis-extras','lib')
      cp(cjk_from, cjk_to) unless File.exists?(File.join(cjk_to, 'CJKFoldingFilter.jar'))
    end

    desc 'Posts fixtures to Solr'
    task :index do
      solr = RSolr.connect :url => Blacklight.connection_config[:url]
      docs = JSON.parse(File.read('spec/fixtures/current_fixtures.json'))
      solr.add docs
      solr.update data: '<commit/>'
    end


    desc 'Delete fixtures from Solr'
    task :deindex do
      solr = RSolr.connect :url => Blacklight.connection_config[:url]
      solr.update data: '<delete><query>*:*</query></delete>'
      solr.update data: '<commit/>'
    end
  end
end

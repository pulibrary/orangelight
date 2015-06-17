require 'rsolr'
require 'json'

namespace :pulsearch do
  desc "Copies solr config files to Jetty wrapper"
  task solr2jetty: :environment do
		cp Rails.root.join('solr_conf','solr.xml'), Rails.root.join('jetty','solr')
		cp Rails.root.join('solr_conf','conf','schema.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')
		cp Rails.root.join('solr_conf','conf','solrconfig.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')	
		cp Rails.root.join('solr_conf', 'core.properties'), Rails.root.join('jetty','solr', 'blacklight-core')
  end
  
  desc "Reset jetty"
  task :rejetty do
    Rake::Task["jetty:stop"].invoke
    Rake::Task["jetty:clean"].invoke
    Rake::Task["jetty:start"].invoke        
  end

  desc "Posts fixtures to Solr"
  task :index do
    solr = RSolr.connect :url => Blacklight.connection_config[:url]
    docs = JSON.parse(File.read('spec/fixtures/current_fixtures.json'))
    solr.add docs
    solr.update :data => '<commit/>'     
  end

  desc "Delete fixtures from Solr"
  task :deindex do
    solr = RSolr.connect :url => Blacklight.connection_config[:url]
    solr.delete_by_query '*.*'
    solr.update :data => '<commit/>'      
  end

  desc "Delete solr index then post fixtures to Solr"
  task :reindex do
    Rake::Task["pulsearch:deindex"].invoke
    Rake::Task["pulsearch:index"].invoke    
  end  

end

require './lib/orangelight/browse_lists'

namespace :browse do
  desc "Pull data for names browse"
  task :names do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.browse_facet(sql_command, facet_request, conn, 'author_s', 'orangelight_names')
  end

  desc "Pull data for subjects browse"
  task :subjects do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.browse_facet(sql_command, facet_request, conn, 'subject_facet', 'orangelight_subjects')
  end

  desc "Pull data for call numbers browse"
  task :call_numbers do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.browse_cn(sql_command, facet_request, conn, 'call_number_browse_s', 'orangelight_call_numbers')
  end

  desc "Pull data for names browse"
  task :load_names do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.load_facet(sql_command, facet_request, conn, 'author_s', 'orangelight_names')
  end

  desc "Pull data for subjects browse"
  task :load_subjects do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.load_facet(sql_command, facet_request, conn, 'subject_facet', 'orangelight_subjects')
  end

  desc "Sort and load call numbers"
  task :load_call_numbers do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s', 'orangelight_call_numbers')
  end

  desc "Pull data for all browse tables"
  task :all do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.browse_facet(sql_command, facet_request, conn, 'author_s', 'orangelight_names')
    BrowseLists.browse_facet(sql_command, facet_request, conn, 'subject_facet', 'orangelight_subjects')
    BrowseLists.browse_cn(sql_command, facet_request, conn, 'call_number_browse_s', 'orangelight_call_numbers')
  end

  desc "Sort and load data for all browse tables"
  task :load_all do
    sql_command, facet_request, conn = BrowseLists.get_connection
    BrowseLists.load_facet(sql_command, facet_request, conn, 'author_s', 'orangelight_names')
    BrowseLists.load_facet(sql_command, facet_request, conn, 'subject_facet', 'orangelight_subjects')
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s', 'orangelight_call_numbers')
  end

end
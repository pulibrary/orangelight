namespace :pulsearch do
  desc "Copies solr config files to Jetty wrapper"
  task solr2jetty: :environment do
	cp Rails.root.join('solr_conf','solr.xml'), Rails.root.join('jetty','solr')
	cp Rails.root.join('solr_conf','conf','schema.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')
	cp Rails.root.join('solr_conf','conf','solrconfig.xml'), Rails.root.join('jetty','solr','blacklight-core','conf')	
  end

end

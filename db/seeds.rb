# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)




# req = eval(Net::HTTP.get("pulsearch-dev.princeton.edu", path ="/orangelight/blacklight-core/select?q=*%3A*&wt=ruby&indent=true&facet=true&fl=id&facet.field=author_s&facet.sort=asc&facet.limit=-1", port=8080))
req = eval(Net::HTTP.get("localhost", path ="/solr/blacklight-core/select?q=*%3A*&wt=ruby&indent=true&facet=true&fl=id&facet.field=author_s&facet.sort=asc&facet.limit=-1&defType=edismax", port=8983))
browsable = Orangelight::Name.new()
req["facet_counts"]["facet_fields"]["author_s"].each do |name|
	if name.is_a?(Integer)
		browsable.count = Integer(name)
		browsable.save!
		browsable = Orangelight::Name.new()
	else
		browsable.label = name
	end
end

req = eval(Net::HTTP.get("localhost", path ="/solr/blacklight-core/select?q=*%3A*&wt=ruby&indent=true&facet=true&fl=id&facet.field=subject_topic_facet&facet.sort=asc&facet.limit=-1&defType=edismax", port=8983))
browsable = Orangelight::Subject.new()
req["facet_counts"]["facet_fields"]["subject_topic_facet"].each do |name|
	if name.is_a?(Integer)
		browsable.count = Integer(name)
		browsable.save!
		browsable = Orangelight::Subject.new()
	else
		browsable.label = name
	end
end
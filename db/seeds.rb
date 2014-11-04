# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

extend BlacklightHelper


host = "localhost"
core = "/solr/blacklight-core"
suffix = "&defType=edismax"
prt = 8983

# changes for different facet queries
query = "&facet=true&fl=id&facet.field=author_s&facet.sort=asc&facet.limit=-1"
# req = eval(Net::HTTP.get("pulsearch-dev.princeton.edu", path ="/orangelight/blacklight-core/select?q=*%3A*&wt=ruby&indent=true&facet=true&fl=id&facet.field=author_s&facet.sort=asc&facet.limit=-1", port=8080))
req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
browsable = Orangelight::Name.new()
req["facet_counts"]["facet_fields"]["author_s"].each do |name|
	if name.is_a?(Integer)
		browsable.count = name.to_i

		browsable.save!
		browsable = Orangelight::Name.new()
	else
		browsable.label = name
		browsable.dir = getdir(name)
	end
end

query = "&facet=true&fl=id&facet.field=subject_facet&facet.sort=asc&facet.limit=-1"
req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
browsable = Orangelight::Subject.new()
req["facet_counts"]["facet_fields"]["subject_facet"].each do |subject|
	if subject.is_a?(Integer)
		browsable.count = subject.to_i
		browsable.save!
		browsable = Orangelight::Subject.new()
	else
		browsable.label = subject
		browsable.dir = getdir(subject)		
	end
end

query = "&rows=999999999"
req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
browsable = Orangelight::CallNumber.new()
req["response"]["docs"].each do |name|
	if name["call_number_display"]
		name["call_number_display"].each do |cn|
			browsable.bibid = name["id"].to_i
			browsable.title = name["title_display"][0] if name["title_display"]
			browsable.label = cn
			browsable.author = name["author_s"][0] if name["author_s"]
			browsable.date = name["pub_created_display"][0] if name["pub_created_display"]
			browsable.save!
			browsable = Orangelight::CallNumber.new()
		end
	end
end
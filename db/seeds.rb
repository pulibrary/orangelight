# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'stringex'

require 'lcsort'
require 'rsolr'

extend BlacklightHelper


if Rails.env == "development"
	host = "localhost"
	core = "/solr/blacklight-core"
	dtype = "edismax"
	suffix = "&defType=edismax"
	prt = 8983
elsif Rails.env = "production"
	host = "pulsearch-dev.princeton.edu"
	core = "/orangelight/blacklight-core"
	dtype = "edismax"
	suffix = "&defType=edismax"
	prt = 8080
else
	host = "localhost"
	core = "/solr/blacklight-core"
	dtype = "edismax"
	suffix = "&defType=edismax"
	prt = 8888	
end




# changes for different facet queries

solr = RSolr.connect :url => "http://#{host}:#{prt}/#{core}", :read_timeout => 9999999


##### NAMES ######

# query = "&facet=true&fl=id&facet.field=author_sort_s&facet.sort=asc&facet.limit=-1&facet.pivot=author_sort_s,author_s"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt))
req = solr.get 'select', :params => {facet: true,
	fl: 'id',
	'facet.field' => 'author_sort_s',
	'facet.sort' => 'asc',
	'facet.limit' => '-1',
	'facet.pivot' => 'author_sort_s,author_s',
	defType: dtype}
req["facet_counts"]["facet_pivot"]["author_sort_s,author_s"].each do |name|
	browsable = Orangelight::Name.new()
	browsable.sort = name["value"]
	browsable.label = name["pivot"][0]["value"]
	browsable.count = name["pivot"][0]["count"].to_i
	browsable.dir = "ltr"  #only non-alternate script fields have this special author_sort_s field
	browsable.save!
end

# query = "&facet=true&fl=id&facet.field=author_vern_s&facet.sort=asc&facet.limit=-1"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
req = solr.get 'select', :params => {facet: true,
	fl: 'id',
	'facet.field' => 'author_vern_s',
	'facet.sort' => 'asc',
	'facet.limit' => '-1',
	'facet.pivot' => 'author_sort_s,author_s',
	defType: dtype}
browsable = Orangelight::Name.new()
req["facet_counts"]["facet_fields"]["author_vern_s"].each do |name|
	if name.is_a?(Integer)
		browsable.count = name.to_i
		browsable.save!
		browsable = Orangelight::Name.new()
	else
		browsable.label = name
		browsable.sort = name
		browsable.dir = getdir(name)
	end
end






##### SUBJECTS #####

# query = "&facet=true&fl=id&facet.field=subject_sort_facet&facet.sort=asc&facet.limit=-1&facet.pivot=subject_sort_facet,subject_facet"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))

# offs = 8192
# lim = 8192
# notempty = true
# while notempty do
	req = solr.get 'select', :params => {facet: true,
		fl: 'id',
		'facet.field' => 'subject_sort_facet',
		'facet.sort' => 'asc',
		'facet.limit' => -1,
		#'facet.offset' => offs,
		'facet.pivot' => 'subject_sort_facet,subject_facet',
		defType: dtype}
	req["facet_counts"]["facet_pivot"]["subject_sort_facet,subject_facet"].each do |subject|
		browsable = Orangelight::Subject.new()
		browsable.sort = subject["value"]
		subject["pivot"].each do |sub_display|
			browsable.label = sub_display["value"] if subject["value"] == sub_display["value"].gsub('—', ' ').gsub(/[\p{P}\p{S}]/, '').remove_formatting.downcase
		end
		browsable.count = subject["pivot"][0]["count"].to_i
		browsable.dir = "ltr"  #only non-alternate script fields have this special subject_sort_facet field
		browsable.save!
	end
# 	notempty = req["facet_counts"]["facet_pivot"]["subject_sort_facet,subject_facet"].length != 0
# 	offs += lim
# end

# query = "&facet=true&fl=id&facet.field=subject_vern_facet&facet.sort=asc&facet.limit=-1"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
req = solr.get 'select', :params => {facet: true,
	fl: 'id',
	'facet.field' => 'subject_vern_facet',
	'facet.sort' => 'asc',
	'facet.limit' => '-1',
	defType: dtype}
browsable = Orangelight::Subject.new()
req["facet_counts"]["facet_fields"]["subject_vern_facet"].each do |subject|
	if subject.is_a?(Integer)
		browsable.count = subject.to_i
		browsable.save!
		browsable = Orangelight::Subject.new()
	else
		browsable.label = subject
		browsable.sort = subject.gsub('—', ' ')
		browsable.dir = getdir(subject)		
	end
end




###### CALL NUMBERS #######

# query = "&rows=999999999"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))
req = solr.get 'select', :params => {rows: 999999999,
	defType: dtype}
req["response"]["docs"].each do |name|
	if name["call_number_display"]
		name["call_number_display"].each do |cn|
			browsable = Orangelight::CallNumber.new()
			browsable.bibid = name["id"].to_i
			browsable.title = name["title_display"][0] if name["title_display"]
			#puts cn
			#browsable.sort = cn
			browsable.sort = Lcsort.normalize(cn)
			browsable.label = cn
			browsable.author = name["author_s"][0] if name["author_s"]
			browsable.date = name["pub_created_display"][0] if name["pub_created_display"]
			browsable.save!
		end
	end
end

cnt = Orangelight::CallNumber.count
i = 1

while i <= cnt do
#Orangelight::CallNumber.find_each do |callno|
	callno = Orangelight::CallNumber.find(i)
  callno.id = callno.id + cnt
  callno.save
  i += 1
end


lim = 512
off = 0
newid = 1
while off <= cnt do
	batch = Orangelight::CallNumber.order(:sort).limit(lim).offset(off)
	batch.each do |callno|
		callno.id = newid
		newid += 1
		callno.save
	end
	off += lim
end

Orangelight::CallNumber.where('id > ?', cnt).each do |please_delete|
	please_delete.destroy
end

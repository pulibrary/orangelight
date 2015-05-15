# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require 'lcsort'
require 'rsolr'
require 'csv'

extend BlacklightHelper


# if Rails.env == "development"
# 	host = "localhost"
# 	core = "/solr/blacklight-core"
# 	dtype = "edismax"
# 	suffix = "&defType=edismax"
# 	prt = 8983
# elsif ENV['TRAVIS']
# 	host = "localhost"
# 	core = "/solr/blacklight-core"
# 	dtype = "edismax"
# 	suffix = "&defType=edismax"
# 	prt = 8888	
# else 
# 	host = "pulsearch-dev.princeton.edu"
# 	core = "/orangelight/blacklight-core"
# 	dtype = "edismax"
# 	suffix = "&defType=edismax"
# 	prt = 8080	
# end

puts 
config = Orangelight::Application.config.database_configuration[::Rails.env]
dbhost, dbuser, dbname, password = config['host'], config['username'], config['database'], config['password']
sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} #{dbname} -c"


# changes for different facet queries

#solr = RSolr.connect :url => "http://#{host}:#{prt}/#{core}", :read_timeout => 9999999
solr = Blacklight.solr

##### NAMES ######
unless ENV['STEP'] == '1'
	unless ENV['STEP'] == '2'	
		# query = "&facet=true&fl=id&facet.field=author_sort_s&facet.sort=asc&facet.limit=-1&facet.pivot=author_sort_s,author_s"
		# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt))
		req = solr.get 'select', :params => {facet: true,
			fl: 'id',
			'facet.field' => 'author_s',
			'facet.sort' => 'asc',
			'facet.limit' => '-1'
		}
		# req["facet_counts"]["facet_pivot"]["author_sort_s,author_s"].each do |name|
		# 	browsable = Orangelight::Name.new()
		# 	browsable.sort = name["value"]
		# 	name["pivot"].each do |name_display|
		# 		browsable.label = name_display["value"] if name["value"] == name_display["value"].normalize_em
		# 	end	
		# 	browsable.count = name["count"].to_i
		# 	browsable.dir = getdir(browsable.label) 
		# 	browsable.save!
		# end

		CSV.open("/tmp/authors.csv", "wb") do |csv|
		  label = ''
		  req["facet_counts"]["facet_fields"]["author_s"].each_with_index do |fac, i|
		    if i.even?
		      label = fac
		    else
		      csv << [label.normalize_em, fac.to_s, label, getdir(label)]
		    end
		  end    		
		end

		system(%Q(#{sql_command} "\\copy orangelight_names(sort,count,label,dir) from '/tmp/authors.csv' CSV;"))
		system(%Q(#{sql_command} \"\\copy (Select sort,count,label,dir from orangelight_names order by sort) To '/tmp/authors.sorted' With CSV;"))
		system(%Q(#{sql_command} "TRUNCATE TABLE orangelight_names RESTART IDENTITY;"))
		system(%Q(#{sql_command} "\\copy orangelight_names(sort,count,label,dir) from '/tmp/authors.sorted' CSV;"))


	end  #STEP 2



##### SUBJECTS #####

	# query = "&facet=true&fl=id&facet.field=subject_sort_facet&facet.sort=asc&facet.limit=-1&facet.pivot=subject_sort_facet,subject_facet"
	# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))


		req = solr.get 'select', :params => {facet: true,
			fl: 'id',
			'facet.field' => 'subject_facet',
			'facet.sort' => 'asc',
			'facet.limit' => -1
		}
		# req["facet_counts"]["facet_pivot"]["subject_sort_facet,subject_facet"].each do |subject|
		# 	browsable = Orangelight::Subject.new()
		# 	browsable.sort = subject["value"]
		# 	subject["pivot"].each do |sub_display|
		# 		browsable.label = sub_display["value"] if subject["value"] == sub_display["value"].normalize_em
		# 	end
		# 	browsable.count = subject["count"].to_i
		# 	browsable.dir = getdir(browsable.label)
		# 	browsable.save!
		# end
		CSV.open("/tmp/subjects.csv", "wb") do |csv|
	    label = ''
	    req["facet_counts"]["facet_fields"]["subject_facet"].each_with_index do |fac, i|
        if i.even?
          label = fac
        else
          csv << [label.normalize_em, fac.to_s, label, getdir(label)]
        end
	    end    
		end		

		system(%Q(#{sql_command} "\\copy orangelight_subjects(sort,count,label,dir) from '/tmp/subjects.csv' CSV;"))
		system(%Q(#{sql_command} "\\copy (Select sort,count,label,dir from orangelight_subjects order by sort) To '/tmp/subjects.sorted' With CSV;"))
		system(%Q(#{sql_command} "TRUNCATE TABLE orangelight_subjects RESTART IDENTITY;"))
		system(%Q(#{sql_command} "\\copy orangelight_subjects(sort,count,label,dir) from '/tmp/subjects.sorted' CSV;"))

		# query = "&facet=true&fl=id&facet.field=subject_vern_facet&facet.sort=asc&facet.limit=-1"
		# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))

		####### TRYING WITH JUST ONE INDEX #########
		# req = solr.get 'select', :params => {facet: true,
		# 	fl: 'id',
		# 	'facet.field' => 'subject_vern_facet',
		# 	'facet.sort' => 'asc',
		# 	'facet.limit' => '-1',
		# 	defType: dtype}
		# browsable = Orangelight::Subject.new()
		# req["facet_counts"]["facet_fields"]["subject_vern_facet"].each do |subject|
		# 	if subject.is_a?(Integer)
		# 		browsable.count = subject.to_i
		# 		browsable.save!
		# 		browsable = Orangelight::Subject.new()
		# 	else
		# 		browsable.label = subject
		# 		browsable.sort = subject.gsub('—', ' ')
		# 		browsable.dir = getdir(subject)		
		# 	end
		# end




end #STEP 1



###### CALL NUMBERS #######

# query = "&rows=999999999"
# req = eval(Net::HTTP.get(host, path ="#{core}/select?q=*%3A*&wt=ruby&indent=true#{query}#{suffix}", port=prt).force_encoding("UTF-8"))


req = solr.get 'select', :params => {facet: true,
	fl: 'id',
	'facet.field' => 'call_number_browse_s',
	'facet.sort' => 'asc',
	'facet.limit' => -1,
	'facet.mincount' => 2 
}

CSV.open("/tmp/call_numbers.csv", "wb") do |csv|
  mcn = ''
  multi_cns = {}
  req["facet_counts"]["facet_fields"]["call_number_browse_s"].each_with_index do |f, i|
    if i.even?
      mcn = f
    else
      sort_cn = Lcsort.normalize(mcn)
      multi_cns[sort_cn] = f
      csv << [sort_cn, mcn, "ltr", "", "#{f} records for this call number", "", "", "?f[call_number_browse_s][]=#{sort_cn}"]
    end
  end

	req = solr.get 'select', :params => {rows: 999999999,
		fl: "call_number_browse_s,title_display,title_vern_display,author_display,id,pub_created_display",
		facet: false
	}
  req["response"]["docs"].each do |record|
    if record["call_number_browse_s"]
      record["call_number_browse_s"].each_with_index do |cn, i|
        sort_cn = Lcsort.normalize(cn)                      
        unless multi_cns.has_key?(sort_cn)

          bibid = record["id"]
          title = record["title_display"][0] if record["title_display"]
          if record["title_vern_display"]
            title = record["title_vern_display"] 
            dir = getdir(title)
          else
            dir = "ltr"  #ltr for non alt script
          end
          label = cn
          author = record["author_display"][0..1].last if record["author_display"]
          date = record["pub_created_display"][0..1].last if record["pub_created_display"]
          csv << [sort_cn,label,dir,"",title,author,date,bibid]
        end
      end
    end        
  end
end

system(%Q(#{sql_command} "\\copy orangelight_call_numbers(sort,label,dir,scheme,title,author,date,bibid) from '/tmp/call_numbers.csv' CSV;"))
system(%Q(#{sql_command} "\\copy (Select sort,label,dir,scheme,title,author,date,bibid from orangelight_call_numbers order by sort) To '/tmp/call_numbers.sorted' With CSV;"))
system(%Q(#{sql_command} "TRUNCATE TABLE orangelight_call_numbers RESTART IDENTITY;"))
system(%Q(#{sql_command} "\\copy orangelight_call_numbers(sort,label,dir,scheme,title,author,date,bibid) from '/tmp/call_numbers.sorted' CSV;"))

# call_number_text = ''
# req["facet_counts"]["facet_fields"]["call_number_s"].each_with_index do |call_number, i|
# 	if i.even?
# 		call_number_text = call_number
# 	else 
# 		call_number_label = ''
# 		req = solr.get 'select', :params => {rows: 999999999,
# 			fl: "call_number_s,call_number_browse_s,title_display,title_vern_display,author_display,id,pub_created_display",
# 			q: "call_number_s:#{call_number_text}",
# 			sort: "sort=title_sort asc",
# 			defType: dtype}
# 		req["response"]["docs"].each do |name|
# 			if name["call_number_s"]
# 				name["call_number_s"].each_with_index do |cn, j|
# 					if cn == call_number_text						
# 						call_number_label = name["call_number_browse_s"][j]
# 						if call_number.to_i == 1
# 							browsable = Orangelight::CallNumber.new()
# 							browsable.bibid = name["id"].to_i
# 							browsable.title = name["title_display"][0] if name["title_display"]
# 							if name["title_vern_display"]
# 								browsable.title = name["title_vern_display"] 
# 								browsable.dir = getdir(browsable.title)
# 							else
# 								browsable.dir = "ltr"  #ltr for non alt script
# 							end
# 							#puts cn
# 							browsable.sort = cn
# 							#browsable.label = cn
# 							browsable.label = name["call_number_browse_s"][j]
# 							browsable.author = name["author_display"][0..1].last if name["author_display"]
# 							browsable.date = name["pub_created_display"][0..1].last if name["pub_created_display"]
# 							browsable.save!
# 						end
# 					end
# 				end
# 			end
# 		end
# 		if call_number.to_i > 1 and call_number_label != ''
# 			browsable = Orangelight::CallNumber.new()
# 			browsable.sort = call_number_text
# 			browsable.label = call_number_label 
# 			browsable.title =	"#{call_number} records for this call number"
# 			browsable.dir = "ltr"
# 			browsable.bibid = "?f[call_number_browse_s][]=#{call_number_label}"
# 			browsable.save!
# 		end
# 	end
# end

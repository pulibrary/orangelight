# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require 'lcsort'
require 'csv'
require 'faraday'
require 'yajl/json_gem'

extend BlacklightHelper

config = Orangelight::Application.config.database_configuration[::Rails.env]
dbhost, dbuser, dbname, password = config['host'], config['username'], config['database'], config['password']
sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} #{dbname} -c"


# changes for different facet queries
facet_request = '/solr/blacklight-core/select?q=*%3A*&fl=id&wt=json&indent=true&defType=edismax&facet.sort=asc&facet.limit=-1&facet.field='
solr_url = Blacklight.connection_config[:url]

conn = Faraday.new(:url => solr_url) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end


##### NAMES ######
unless ENV['STEP'] == '1'
	unless ENV['STEP'] == '2'	
		facet_field = 'author_s'
		resp = conn.get "#{facet_request}#{facet_field}"
		req = JSON.parse(resp.body)
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


		facet_field = 'subject_facet'
		resp = conn.get "#{facet_request}#{facet_field}"
		req = JSON.parse(resp.body)
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





end #STEP 1



###### CALL NUMBERS #######



facet_field = 'call_number_browse_s&facet.mincount=2'
resp = conn.get "#{facet_request}#{facet_field}"
req = JSON.parse(resp.body) 

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

  # 0: call_number_browse_s
  # 1: title_display
  # 2: title_vern_display
  # 3: author_display
  # 4: id
  # 5: pub_created_display
  #`curl 'http://lib-solr1.princeton.edu:8985/solr/blacklight-core/select?rows=9999999&fl=call_number_browse_s%2Ccall_number_s%2Ctitle_display%2Ctitle_vern_display%2Cauthor_display%2Cid%2Cpub_created_display&wt=csv&indent=true&defType=edismax&stopwords=true&lowercaseOperators=true&facet=false' > /tmp/cns.csv`
  # CSV.foreach("path/to/file.csv") do |record|
	cn_fields = "call_number_browse_s,title_display,title_vern_display,author_display,id,pub_created_display"
	cn_request = "/solr/blacklight-core/select?q=*%3A*&fl=#{cn_fields}&wt=json&indent=true&defType=edismax&facet=false&rows=9999999"
	resp = conn.get "#{cn_request}"  
	req = JSON.parse(resp.body) 
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


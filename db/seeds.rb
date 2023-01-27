# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

config = Orangelight::Application.config.database_configuration[::Rails.env]
dbhost, dbuser, dbname, password, port = config['host'], config['username'], config['database'], config['password'], config['port'] || 5432
sql_command = "PGPASSWORD=#{password} psql -U #{dbuser} -h #{dbhost} -p #{port} #{dbname} -c"

system(%Q(#{sql_command} "TRUNCATE TABLE #{BrowseLists.table_prefix}_names RESTART IDENTITY;"))
system(%Q(#{sql_command} "TRUNCATE TABLE #{BrowseLists.table_prefix}_name_titles RESTART IDENTITY;"))
system(%Q(#{sql_command} "TRUNCATE TABLE #{BrowseLists.table_prefix}_subjects RESTART IDENTITY;"))
system(%Q(#{sql_command} "TRUNCATE TABLE #{BrowseLists.table_prefix}_call_numbers RESTART IDENTITY;"))
system(%Q(#{sql_command} "\\copy #{BrowseLists.table_prefix}_names(sort,count,label,dir) from 'spec/fixtures/authors.sorted' CSV;"))
system(%Q(#{sql_command} "\\copy #{BrowseLists.table_prefix}_name_titles(sort,count,label,dir) from 'spec/fixtures/name_titles.sorted' CSV;"))
system(%Q(#{sql_command} "\\copy #{BrowseLists.table_prefix}_subjects(sort,count,label,dir,vocabulary) from 'spec/fixtures/subjects.sorted' CSV;"))
system(%Q(#{sql_command} "\\copy #{BrowseLists.table_prefix}_call_numbers(sort,label,dir,scheme,title,author,date,bibid,holding_id,location) from 'spec/fixtures/call_numbers.sorted' CSV;"))


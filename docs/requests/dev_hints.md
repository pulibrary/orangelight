# Development hints for Requests
## Start up Bibdata for Orangelight development
- Make sure you have the Alma keys for Bibdata set up - see [info in the Bibdata readme](https://github.com/pulibrary/bibdata#configure-alma-keys-for-development)
- Start the Bibdata support application servers `bundle exec rails servers:start`
- Start the Bibdata server on a non-standard port  `bundle exec rails s -p 3001` (Question: Should this point to the Orangelight Solr? Or does it matter?)

## Start up Orangelight
- Start the Orangelight support servers `bundle exec rake servers:start`
- Start up the Orangelight server, pointing to the local Bibdata instance 
```BASH
BIBDATA_BASE=http://localhost:3001 bundle exec rails s
```

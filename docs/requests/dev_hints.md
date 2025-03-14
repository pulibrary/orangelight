# Development hints for Requests
## Start up Bibdata for Orangelight development
- Make sure you have the Alma keys for Bibdata set up - see [info in the Bibdata readme](https://github.com/pulibrary/bibdata#configure-alma-keys-for-development)
- Start the Bibdata support application servers `bundle exec rake servers:start`
- Start the Bibdata server on a non-standard port  `bundle exec rails s -p 3001` (Question: Should this point to the Orangelight Solr? Or does it matter?)
- Make sure that there are locations displaying at http://localhost:3001/locations/holding_locations.  If not, run `bundle exec rake bibdata:delete_and_repopulate_locations`.

## Start up Orangelight
- Start the Orangelight support servers `bundle exec rake servers:start`
- If you will be making a hold request in Alma, you will need a read/write alma key.  To get the sandbox read/write key from the staging catalog server if you are on the VPN, you can run `export $(ssh deploy@catalog-staging2 "env | grep ALMA_READ_WRITE")`
- Start up the Orangelight server, pointing to the local Bibdata instance 
```BASH
BIBDATA_BASE=http://localhost:3001 bundle exec rails s
```
- Start mailcatcher if you want to review the emails sent: `mailcatcher`

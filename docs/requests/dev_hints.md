# Development hints for Requests
## Start up Bibdata for Orangelight development
1. The LDAP keys are neccessary to connect to your library account. Make sure you have the Alma/SCSB and LDAP keys for Bibdata set up - see [info in the Bibdata readme](https://github.com/pulibrary/bibdata#configure-alma-keys-for-development). The rake task will only retrieve the Alma keys. 
Make sure to include the SCSB keys if you want to test SCSB requests. 
If the rake task does not work get the Alma with the SCSB and LDAP keys from the bibdata staging or production machine and include them in step 3 example: `ALMA_REGION=ALMA_REGION_key bundle exec rails s -p 3001`
2. Start the Bibdata support application servers `bundle exec rake servers:start`
3. Start the Bibdata server on a non-standard port  `bundle exec rails s -p 3001`. Make sure that you use the LDAP and the rest of keys - see step 1.
4. Make sure that there are locations displaying at http://localhost:3001/locations/holding_locations.  If not, run `bundle exec rake bibdata:delete_and_repopulate_locations`.

## Start up Orangelight
1. Start the Orangelight support servers `bundle exec rake servers:start`
2. In step 1, Include the Illiad keys if you want to test Illiad requests. 
3. In step 1, Include the SCSB keys if you want to test SCSB requests.
4. If you will be making a hold request in Alma, you will need a read/write alma key.  To get the sandbox read/write key from the staging catalog server if you are on the VPN, you can run `export $(ssh deploy@catalog-staging2 "env | grep ALMA_READ_WRITE")`
- Start up the Orangelight server, pointing to the local Bibdata instance 
```BASH
BIBDATA_BASE=http://localhost:3001 bundle exec rails s
```
- Start mailcatcher if you want to review the emails sent: `mailcatcher`

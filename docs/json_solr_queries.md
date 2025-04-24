### Troubleshooting JSON queries via curl

Sending queries to solr directly via curl can be useful when troubleshooting or performance tuning a query.

### Sending JSON queries locally via curl

To send a json query to your local solr, you will need two pieces of information:
1. The url of your local solr's request handler
2. The JSON you would like to send to solr

One way to get the above information is to place a byebug into rsolr:
1. Open the rsolr in the orangelight bundle (with vs code: `code $(bundle show rsolr)`)
2. Find the `RSolr::Client#execute` method in lib/rsolr/client.rb
3. Place your `byebug` on the line under the line that starts with `req.body`
4. Run a test or use the UI to perform a query that is similar to the one you want to `curl`
5. In your debugger, you can get the URL from `request_context[:uri].to_s` and the JSON from `request_context[:data]`

You can then send a curl from your terminal in the format:

```
curl -H "Content-Type: application/json" -d 'JSON GOES HERE' 'SOLR REQUEST HANDLER URL GOES HERE'
```

### Experimenting with small local collection
There are two very small solr collections built specifically for testing booleans (the tests are in [boolean_searching_spec](../spec/system/boolean_searching_spec.rb)). 

First run a test that uses the collection you want to experiment with - that will put the right documents in the Solr collection.

Then you can use `curl` to experiment with different queries against that core.

Your json:
```json
{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe AND date)"}}}
```

Your bash commands:
```bash
TEST_JSON='{"query":{"edismax":{"query": "(apple OR squishy) AND title_display:(cantaloupe AND date)"}}}'
curl -H "Content-Type: application/json" -d $TEST_JSON 'http://orangelight.test.small.solr.lndo.site/solr/orangelight-core-small-test/advanced?wt=json'
```

### Sending JSON queries to production 

1. `ssh -L 1234:localhost:8983 deploy@lib-solr-prod9`
2. `curl -H "Content-Type: application/json" -d 'JSON GOES HERE' 'http://localhost:1234/solr/catalog-alma-production/advanced'`

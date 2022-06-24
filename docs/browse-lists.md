# Browse Lists
## URLs for the different Browse lists
* [Subject Browse](https://catalog.princeton.edu/browse/subjects?search_field=browse_subject&q=.)
* [Name Browse](https://catalog.princeton.edu/browse/names?search_field=browse_name&q=)
* [Title Browse](https://catalog.princeton.edu/browse/name_titles?search_field=name_title&q=)
* [Call Number Browse](https://catalog.princeton.edu/browse/call_numbers?search_field=browse_cn&q=)

## How to know which machine to use

- Check [schedule.rb in Orangelight](https://github.com/pulibrary/orangelight/blob/main/config/schedule.rb#L27) to find which logical machine a rake task is running on.  Then see which host that is in [production.rb](https://github.com/pulibrary/orangelight/blob/main/config/deploy/production.rb#L19-L21)

## Generating browse lists

To fully regenerate **all browse lists**: (Note: Expected time: 5.5 - 6 hours)

For catalog-staging, ssh to a staging box (there are no workers for catalog-staging and the rake task needs to run on the catalog box).
  ```
  ssh deploy@catalog-staging1
  cd /opt/orangelight/current
  OL_DB_PORT=5432 bundle exec rake browse:all && OL_DB_PORT=5432 bundle exec rake browse:load_all >> log/browselist.log 2>&1 &
  ```

For catalog production
  ```
  ssh deploy@catalog-indexer1
  cd /opt/orangelight/current
  OL_DB_PORT=5432 bundle exec rake browse:all && OL_DB_PORT=5432 bundle exec rake browse:load_all >> log/browselist.log 2>&1 &
  ```

## Troubleshooting

### Subject List

 Is used in `Subject (browse)` in Orangelight. 

Potential failure to populate successfully the subjects table will result to an empty https://catalog.princeton.edu/browse/subjects?search_field=browse_subject&q= view or a list with a small count (current count = 8,902,603).

Fix:
- Find which machine to use from section: `How to know which machine to use`. Currently the `call_numbers` task is deployed to run on `catalog-indexer3`.
- SSH as `deploy` user to the machine used to produce the subjects lists

- Run the first rake task to generate the CSV file from solr data:
- `cd /opt/orangelight/current`
- `OL_DB_PORT=5432 bundle exec rake browse:subjects`

Expected time 1.5-2 hours.

- Run the second rake task to upload the CSV file in the postgres table:
- `cd /opt/orangelight/current`
- `OL_DB_PORT=5432 bundle exec rake browse:load_subjects`

Expected time: Less than 30 minutes.

### Names List
Is used in `Authors (browse)` in Orangelight.
Potential failure to populate successfully the authors table will result to an empty https://catalog.princeton.edu/browse/names?search_field=browse_name&q= view or a list with a small count.

Fix:
- Find which machine to use from section: `How to know which machine to use`. Currently the `call_numbers` task is deployed to run on `catalog-indexer3`.
- SSH as `deploy` user to the machine used to produce the subjects lists
- Create a tmux session (`tmux new -s browse-names`) if one doesn't exist (`tmux ls`).
- `cd /opt/orangelight/current`
- `OL_DB_PORT=5432 bundle exec rake browse:names`
- Detach from your tmux session with Ctrl + B D

Expected time 3 hours.

- Run the second rake task to upload the CSV file in the postgres table:
```
cd /opt/orangelight/current
OL_DB_PORT=5432 bundle exec rake browse:load_names
```
- Detach from your tmux session with Ctrl + B D

### Call Number List
Is used in `Call numbers (browse)` in Orangelight.
Potential failure to populate successfully the call_numbers table will result to an empty https://catalog.princeton.edu/browse/call_numbers?search_field=browse_cn&q= view or a list with a small count (current count = 5,819,908).

Fix:
- Find which machine to use from section: `How to know which machine to use`. Currently the `call_numbers` task is deployed to run on `catalog-indexer1`.
- SSH as `deploy` user to the machine used to produce the subjects lists
- Create a backup of the `/tmp/call_number_browse_s.sorted` file in `/home/deploy/call_number_browse_s.sorted`.
- Count the lines: `wc -l /tmp/call_number_browse_s.sorted`.
- Create a tmux session and run the `call_numbers` rake task:
- `cd /opt/orangelight/current`
- `RAILS_ENV=production SOLR_URL=http://lib-solr-prod4.princeton.edu:8983/solr/catalog-production bundle exec rake browse:call_numbers --silent >> /tmp/cron_log_call_numbers.log 2>&1`

- It takes around 3 hours to complete. When it finishes successfully the output will be on `/tmp/call_number_browse_s.sorted`. Count the lines in the file `wc -l /tmp/call_number_browse_s.sorted` to ensure that there is not a big difference with the backup file which is located in `/home/deploy/call_number_browse_s.sorted` or the most recent file which is located `/tmp/call_number_browse_s.sorted`.
- Then run the `load_call_numbers` rake task to ingest the data. This task expects the input file to be on `/tmp/call_number_browse_s.sorted`:
- `cd /opt/orangelight/current`
- `RAILS_ENV=production SOLR_URL=http://lib-solr8-prod.princeton.edu:8983/solr/catalog-production bundle exec rake browse:load_call_numbers --silent >> /tmp/cron_log.log 2>&1`
# Restoring the catalog from backup

## Restoring solr

In the case of data loss in Solr, follow these steps and confirm
the expected state at the end of each task:

|Step|Expected state|Documentation|
|---|---|---|
|1. Swap the rebuild index|The production catalog site now is searchable again, with outdated data|[cap alias:swap documentation in pul_solr](https://github.com/pulibrary/pul_solr/blob/898fcd8f88ba2a88add4545fb8dd0100523dccc2/config/deploy.rb#L99-L101)|
|2. SSH into a solr box and confirm the presence and size of backups at /mnt/solr_backup|A recent backup exists, is roughly 75 GB in size|[Restoring a backup in pul_solr](https://github.com/pulibrary/pul_solr?tab=readme-ov-file#restoring-a-backup)|
|3. Check the unused disk space on the solr box's root filesystem with `df -h`|The unused disk space is larger than the size of the recent backup|[Restoring a backup in pul_solr](https://github.com/pulibrary/pul_solr?tab=readme-ov-file#restoring-a-backup)|
|4. Run a curl command to start the restore process, including the async parameter|When you open an SSH tunnel to the solr box and look at `http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid={your async id}` in curl or your browser, it says that it is in progress|[Restoring a backup in pul_solr](https://github.com/pulibrary/pul_solr?tab=readme-ov-file#restoring-a-backup)|
|5. Check the request status in about 30 minutes to see if it finished|When you open an SSH tunnel to the solr box and look at `http://localhost:8983/solr/admin/collections?action=REQUESTSTATUS&requestid={your async id}` in curl or your browser, it says "completed"|[Restoring a backup in pul_solr](https://github.com/pulibrary/pul_solr?tab=readme-ov-file#restoring-a-backup)|
|6. In the solr admin UI, do an example search in the new collection|Search results appear||
|7. Swap the new collection into production|The production catalog site now has the data from your recent backup|[cap alias:swap documentation in pul_solr](https://github.com/pulibrary/pul_solr/blob/898fcd8f88ba2a88add4545fb8dd0100523dccc2/config/deploy.rb#L99-L101)|

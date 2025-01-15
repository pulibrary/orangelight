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

## Restoring postgres database

In the case of data loss in Postgres, follow these steps and confirm
the expected state at the end of each task:

|Step|Expected state|Documentation|
|---|---|---|
|1. Open an SSH connection to the production postgres leader machine as pulsys|connection opened successfully|[Leader node in Princeton Ansible](https://github.com/pulibrary/princeton_ansible/blob/main/group_vars/postgres_production_cluster.yml)|
|2. Login as the postgres user with `sudo su - postgres`|Login successful|[Restore from a backup in PUL IT Handbook](https://github.com/pulibrary/pul-it-handbook/blob/main/services/restic_backup.md#restore-from-a-backup)|
|3. Setup the environment variables with `source .env.restic`|`RESTIC_PASSWORD_FILE` and `GOOGLE_APPLICATION_CREDENTIALS` envvars are set to filenames of existing files. `RESTIC_REPOSITORY` and `RESTIC_ARCHIVE_REPOSITORY` envvars are set to "gs", then the name of a Google Cloud bucket, then the name of the folder in that bucket that contains the backups, delimited by ":" |[Restore from a backup in PUL IT Handbook](https://github.com/pulibrary/pul-it-handbook/blob/main/services/restic_backup.md#restore-from-a-backup)|
|4. Find the list of snapshots with `restic -r $RESTIC_REPOSITORY -p $RESTIC_PASSWORD_FILE snapshots`|The list includes a recent orangelight_production.sql.gz|[Restore from a backup in PUL IT Handbook](https://github.com/pulibrary/pul-it-handbook/blob/main/services/restic_backup.md#restore-from-a-backup)|
|5. Using the hash of the recent orangelight_production.sql.gz, restore the .sql.gz file to the /tmp directory with `restic -r $RESTIC_REPOSITORY -p $RESTIC_PASSWORD_FILE restore [hash] -t /tmp`|The .sql.gz file appears in `/tmp/postgresql/`|[Restore from a backup in PUL IT Handbook](https://github.com/pulibrary/pul-it-handbook/blob/main/services/restic_backup.md#restore-from-a-backup)|
|6. Create a new database to house the restored data with `createdb -O orangelight orangelight_production_restore`|A new, empty database is created that is owned by the orangelight user|[createdb docs from postgres](https://www.postgresql.org/docs/15/app-createdb.html)|
|7. scp the .sql.gz file to your local computer with `scp pulsys@lib-postgres-staging1:/tmp/postgresql/orangelight_production.sql.gz .`|The file transfers to your local computer||
|8. scp the .sql.gz file to a catalog application server with `scp orangelight_production.sql.gz deploy@catalog3:~`|The file transfers to the application server, in the deploy user's home directory||
|9. Open an SSH connection to the catalog application server as deploy|connection opened successfully||
|10. Decompress the .sql.gz file with `gunzip orangelight_production.sql.gz`|.gz file disappears, you just have an .sql file now||
|11. In the .sql file, comment out the `DROP DATABASE` and `CREATE DATABASE` lines.|||
|12. In the .sql file, change the `\connect` line to `\connect orangelight_production_restore`|||
|13. Get the `orangelight` postgres user's password with `env \| grep DB_PASSWORD` |password is displayed||
|14. Restore the data into the new `orangelight_production_restore` database with `psql -h $APP_DB_HOST -U orangelight -W -d orangelight_production_restore < orangelight_production.sql`|We can connect to the `orangelight_production_restore` database, `\d` shows all the expected tables, and `SELECT * FROM bookmarks` shows reasonable data.||
|15. In princeton_ansible, update the database in the orangelight group_vars to `orangelight_production_restore`||
|16. Run the orangelight ansible playbook with the `site_config` tag: `ansible-playbook playbooks/orangelight.yml -e runtime_env=production -t site_config`|Production catalog now has a complete database from last night's backup||

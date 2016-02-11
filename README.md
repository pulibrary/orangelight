# Orangelight

[![Join the chat at https://gitter.im/pulibrary/orangelight](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pulibrary/orangelight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/pulibrary/orangelight.png?branch=development)](https://travis-ci.org/pulibrary/orangelight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/orangelight/badge.png?branch=development)](https://coveralls.io/r/pulibrary/orangelight)



Versions:

* Ruby: 2.2.3
* Rails: 4.2.5.1
* Blacklight: 5.18.0
* blacklight_advanced_search: 5.1.2

To install run `bundle install`

Application Configuration
------------------
### Postgres Installation
```bash
apt-get install postgresql
su - postgres
psql -c "CREATE ROLE orangelight with createdb login password 'orange';" 
exit
```

### Database Configruation
```bash
cp config/database.yml.tmpl config/database.yml
rake db:create
rake db:migrate
```
Production credentials: In production you'll need to add production 
credentials to database.yml

### Load Test Data
```bash
rake jetty:clean
rake jetty:start
rake pulsearch:index
rake db:seed
```
### Whitelist Configuration
```bash
cp config/ip_whitelist.yml.tmpl config/ip_whitelist.yml
```

The application controller checks the ip whitelist to determine whether the user has access to the application. When the whitelist is empty, everyone has access to the application. If it contains ip addresses, then only users whose ip address is in the whitelist can access the application.

### Request and Holding 
```bash
cp config/requests.yml.tmpl config/requests.yml
```

Configure various options for PUL Requests.

Deploying with Capistrano
------------------
Default branch for deployment is `development`. You can specify a branch using the BRANCH environment variable.
```
BRANCH=my_branch cap staging deploy # deploys my_branch to staging
cap staging deploy # deploys development branch to staging
```
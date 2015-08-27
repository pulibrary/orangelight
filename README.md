# Orangelight

[![Join the chat at https://gitter.im/pulibrary/orangelight](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pulibrary/orangelight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/pulibrary/orangelight.png?branch=development)](https://travis-ci.org/pulibrary/orangelight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/orangelight/badge.png?branch=development)](https://coveralls.io/r/pulibrary/orangelight)



Versions:

* Ruby: 2.1
* Rails: 4.2.4
* Blacklight: 5.14.0
* blacklight_advanced_search: 5.1.2

To install run `bundle install`

postgresql configuration
------------------

```bash
apt-get install postgresql
su - postgres
psql -c "CREATE ROLE orangelight with createdb login password 'orange';" 
exit
```

### database configruation
```bash
cp config/database.yml.tmpl config/database.yml
```
Production credentials: In production you'll need to add production 
credentials to database.yml

### Load test data
```bash
rake jetty:clean
rake jetty:start
rake pulsearch:index
rake db:seed
```

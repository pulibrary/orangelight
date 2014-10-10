# Orangelight
[![Build Status](https://travis-ci.org/pulibrary/orangelight.png?branch=development)](https://travis-ci.org/pulibrary/orangelight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/orangelight/badge.png)](https://coveralls.io/r/pulibrary/orangelight)

Versions:

* Ruby: 2.1.1
* Blacklight: 5.7.0

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

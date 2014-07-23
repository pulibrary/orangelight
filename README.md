# Orangelight
[![Build Status](https://travis-ci.org/pulibrary/orangelight.png?branch=development)](https://travis-ci.org/pulibrary/orangelight)


Versions:

* Ruby: 2.1.1
* Blacklight: 5.5.2

To install run `bundle install`

postgresql configuration
------------------

```bash
apt-get install postgresql
su - postgres
create role orangelight with createdb login password 'orange'
exit
```

### database configruation
```bash
cp config/database.yml.tmpl config/database.yml
```
Production credentials: In production you'll need to add production 
credentials to database.yml
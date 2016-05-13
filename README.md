# Orangelight

[![Join the chat at https://gitter.im/pulibrary/orangelight](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/pulibrary/orangelight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/pulibrary/orangelight.png?branch=development)](https://travis-ci.org/pulibrary/orangelight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/orangelight/badge.png?branch=development)](https://coveralls.io/r/pulibrary/orangelight)



Versions:

* Ruby: 2.2.3
* Rails: 4.2.6
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

### Database Configuration
```bash
rake db:create
rake db:migrate
rake db:seed
```
Production credentials: In production you'll need to add production 
credentials to database.yml

### Run
```bash
rake server
```

Deploying with Capistrano
------------------
Default branch for deployment is `development`. You can specify a branch using the BRANCH environment variable.
```
BRANCH=my_branch cap staging deploy # deploys my_branch to staging
cap staging deploy # deploys development branch to staging
```

Testing
------------------
### Database Configuration
```bash
rake db:create RAILS_ENV=test
rake db:migrate RAILS_ENV=test
rake db:seed RAILS_ENV=test
```

### Run Tests

```bash
rake ci
```

### Run Tests Separately

```bash
rake server:test
```

Then, in another terminal window:

```bash
rake spec
```

To run a specific test:

```bash
rake spec SPEC=path/to/your_spec.rb:linenumber
```

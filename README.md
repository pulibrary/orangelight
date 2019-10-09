# Orangelight

[![CircleCI](https://circleci.com/gh/pulibrary/orangelight.svg?style=svg)](https://circleci.com/gh/pulibrary/orangelight)
[![Coverage Status](https://coveralls.io/repos/pulibrary/orangelight/badge.png?branch=master)](https://coveralls.io/r/pulibrary/orangelight)



Versions:

* Ruby: 2.4.4
* Rails: 5.1.4
* Blacklight: 7.0.1
* blacklight_advanced_search: 7.0.0.alpha

To install run
  ```
  bundle install
  yarn install
  ```

Application Configuration
------------------
### Postgres Installation
```bash
apt-get install postgresql
su - postgres
psql -c "CREATE ROLE orangelight with createdb login password 'orange';"
exit
```
#### Postgres On Mac
Follow the instructions on [codementor](https://www.codementor.io/engineerapart/getting-started-with-postgresql-on-mac-osx-are8jcopb) to install postgres on a Mac. Then run the following commands to create the orangelight user:
```bash
psql postgres
CREATE ROLE orangelight with createdb login password 'orange';
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
Then, in a separate tab, run:
```
bin/webpack-dev-server
```

Deploying with Capistrano
------------------
Default branch for deployment is `master`. You can specify a branch using the BRANCH environment variable.
```
BRANCH=my_branch cap staging deploy # deploys my_branch to staging
cap staging deploy # deploys master branch to staging
```

Testing
------------------
### Testing prerequisite
```bash
brew install phantomjs
```

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

## Local development with Figgy

Orangelight is configured to use two environment variables in order to query and retrieve [IIIF Manifests](https://iiif.io/api/presentation/2.1/#manifest) for resources linked to catalog records in the [Figgy digital object repository](https://github.com/pulibrary/figgy).  By default, these are provided with the following values:
```bash
GRAPHQL_API_URL=https://figgy.princeton.edu/graphql
FIGGY_URL=https://figgy.princeton.edu
```

This will ensure that Orangelight will search for linked resources in the production environment.  To test against linked resources in the staging environment, please use the following invocation when starting the Rails server:
```bash
GRAPHQL_API_URL=https://figgy-staging.princeton.edu/graphql FIGGY_URL=https://figgy-staging.princeton.edu bundle exec rails s
```

## Local development with browse tables

To start up a copy of the project with a solr index of fixture data
```bash
bundle exec rake server
```
Then, in another terminal window build browse index csv files in /tmp:
```bash
RAILS_ENV=development bundle exec rake browse:all
```

Then, load browse data into the development database:
```bash
RAILS_ENV=development bundle exec rake browse:load_all
```

## Local development with account/request features

You will need a working local copy of https://github.com/pulibrary/marc_liberation.
Set the ```bidata_base``` value in your dev environment to point at this version.

## Running javascript unit tests

`$ yarn install`
`$ yarn test`

Debugging instructions: https://facebook.github.io/jest/docs/en/troubleshooting.html

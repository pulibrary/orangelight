# Orangelight

[![CircleCI](https://circleci.com/gh/pulibrary/orangelight.svg?style=svg)](https://circleci.com/gh/pulibrary/orangelight)
[![Coverage
Status](https://coveralls.io/repos/github/pulibrary/orangelight/badge.svg?branch=master)](https://coveralls.io/github/pulibrary/orangelight?branch=master)


Versions:

* Ruby: 2.6.5
* Rails: 5.2.4
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

### Run the devlopment Environment locally
**All commands are assumed to be run from your local orangelight directory**

1. Start Solr using Lando  
   ```
   lando start
   ```
   *Note: You can stop lando by running `lando stop` and you can start fresh using `lando destroy`*
1. Index data into solr 
    *This step is only required if this is your first time running or you have run a `lando destroy`*
    ```
    rake pulsearch:solr:index
    ```
1. Run a rails server 
   ```
   rails s
   ```
   *This will continue running until you Ctrl C, you will need a new tab or window for the next step*
1. Run webpack to serve assets 
   ```
   bin/webpack-dev-server
   ```

Deploying with Capistrano
------------------
Default branch for deployment is `main`. You can specify a branch using the BRANCH environment variable.
```
BRANCH=my_branch cap staging deploy # deploys my_branch to staging
cap staging deploy # deploys main branch to staging
```

## Staging Mail Catcher
  To see mail that has been sent on the staging server you must ssh tunnel into the server
  ```
  ssh -L 1082:localhost:1080 pulsys@lib-orange-staging1
  ```
  Once the tunnel is open [you can see the mail that has been sent on staging here]( http://localhost:1082/)

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

1. Start lando if it is not already started. 
    *The same lando is used for both test and development.*
   ```
   lando start
   ```
1. Index data into solr 
    *This step is only required if this is your first time running or you have run a `lando destroy`*
   ```
   RAILS_ENV=test rake pulsearch:solr:index
   ``` 
1. Run the all the tests 
    ```
    rake spec
    ```

#### To run a specific test
  1. Run steps one and two above
  1. run the individual test
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

You will need a working local copy of [Bibdata](https://github.com/pulibrary/marc_liberation).
Start the Bibdata server, and then set the ```bidata_base``` value in OrangeLight's `config/requests.yml` file to the local URL where Bibdata is running (e.g., `http://localhost:{port}`).

## Running javascript unit tests

`$ yarn install`
`$ yarn test`

### Debugging jest tests

1. Place a `debugger;` line in your javascript
1. Open up Chrome and type in the address bar: chrome://inspect
1. Click on "Open dedicated DevTools for Node"
1. Back in terminal run `yarn test:debug [path_to_test]` (This has been added to
   package.json)

## Development Mailcatcher

   * Modify `config/environments/development.rb` and add
     ```
     config.action_mailer.delivery_method = :smtp
     config.action_mailer.smtp_settings = {
       :address => "localhost",
       :port => 1025
     }
     ```

   * run mail catcher
     run once
     ```
     gem install mailcatcher
     ```
     run every time
     ```
     mailcatcher
     ```

     [you can see the mail that has been sent here]( http://localhost:1080/)

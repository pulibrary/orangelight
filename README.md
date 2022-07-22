# Orangelight

[![CircleCI](https://circleci.com/gh/pulibrary/orangelight.svg?style=svg)](https://circleci.com/gh/pulibrary/orangelight)
[![Coverage
Status](https://coveralls.io/repos/github/pulibrary/orangelight/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/orangelight?branch=main)

Versions:

* Ruby: 2.7.5
* Rails: 6.0.4.7
* Blacklight: 7.25.3
* blacklight_advanced_search: 7.0.0

### Development pre-requisites
* In order to run locally, you must have Lando installed for your system - see https://docs.lando.dev/getting-started/installation.html.

* If you don't have `yarn` installed you can install it with
  ```bash
  npm install -g yarn
  ```
* You may need to install the bundler referenced in the Gemfile.lock, e.g.
```bash
gem install bundler:2.2.27
```

### Installing the application
To install run
  ```
  bundle install
  yarn install
  ```

On macOS: If the command `yarn install` gives error "No Xcode or CLT version detected" try [re-installing xCode tools](https://medium.com/@mrjohnkilonzi/how-to-resolve-no-xcode-or-clt-version-detected-d0cf2b10a750).

### Run the development Environment locally
**All commands are assumed to be run from your local orangelight directory**

1. Start all the servers/set up database/seed index (this uses Lando to bring up the postgres database, and both the development and test Solr instances)
   ```
   rake servers:start
   ```
   *Note: You can stop everything with `rake servers:stop`

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
### Run Tests

1. Start all the servers/set up database/seed index
   ```
   rake servers:start
   ```
   *Note: You can stop everything with `rake servers:stop`
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
#### Building the browselists
```ruby
RAILS_ENV=test bundle exec rake browse:all
RAILS_ENV=test bundle exec rake browse:load_all
```

#### Refreshing the fixtures
```
rake pulsearch:solr:deindex
rake pulsearch:solr:index
```

### Adding a fixture to the test/dev index

Use an example.xml marc record. Start bibdata in the dev environment. Use the bibdata solr url from lando and run:
`traject -c marc_to_solr/lib/traject_config.rb path-to-xml/example.xml -u http://localhost:<solr-port-number>/solr/name-of-local-solr-index -w Traject::JsonWriter` This will print a JSON. Copy the JSON and add it to the bottom of `spec/fixtures/current_fixtures.json`. Note that file
contains a list so you have to make sure you add a comma to the end of the last
record and keep the closing bracket at the end of the file. Then run `rake pulsearch:solr:index` for both the dev and the test environment, as specified above.

## Update Solr configuration

Run the following command to update pull in Solr configuration updates from the pul_solr repo:

```bash
rake pulsearch:solr:update
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
rake servers:start
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

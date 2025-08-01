# Orangelight

[![CircleCI](https://circleci.com/gh/pulibrary/orangelight.svg?style=svg)](https://circleci.com/gh/pulibrary/orangelight)
[![Coverage
Status](https://coveralls.io/repos/github/pulibrary/orangelight/badge.svg?branch=main)](https://coveralls.io/github/pulibrary/orangelight?branch=main)

Versions:

* Ruby: 3.4.1
* Rails: 7.2
* Blacklight: 8.8

## Development pre-requisites
* In order to run locally, you must have Lando installed for your system - see https://docs.lando.dev/getting-started/installation.html.

* If you don't have `yarn` installed you can install it with
  ```
  npm install -g yarn
  ```
* You may need to install the bundler referenced in the Gemfile.lock, e.g.
  ```
  gem install bundler:2.3.26
  ```

## Installing the application
To install run
  ```
  bundle install
  yarn install
  ```

On macOS: If the command `yarn install` gives error "No Xcode or CLT version detected" try [re-installing xCode tools](https://medium.com/@mrjohnkilonzi/how-to-resolve-no-xcode-or-clt-version-detected-d0cf2b10a750).

## Run the development Environment locally
**All commands are assumed to be run from your local orangelight directory**

1. Start all the servers/set up database/seed index (this uses Lando to bring up the postgres database, and both the development and test Solr instances)
   ```
   bundle exec rake servers:start
   ```
   *Note: You can stop everything with `rake servers:stop`

1. Run a rails server
   ```
   bundle exec rails s
   ```
   *This will continue running until you Ctrl C, you will need a new tab or window for the next step*


Deploying with Capistrano
------------------
Default branch for deployment is `main`. You can specify a branch using the BRANCH environment variable.
```
BRANCH=my_branch bundle exec cap staging deploy # deploys my_branch to staging
bundle exec cap staging deploy # deploys main branch to staging
```

## Staging Mail Catcher
  To see mail that has been sent from the staging environment you must ssh tunnel into the staging indexer servers.
  ```
  ssh -L 1082:localhost:1080 pulsys@catalog-indexer-staging1
  ssh -L 1085:localhost:1080 pulsys@catalog-indexer-staging2
  ```
  To see mail that has been sent on the qa server you must ssh tunnel into the server
  ```
  ssh -L 1082:localhost:1080 pulsys@catalog-indexer-qa1
  ssh -L 1085:localhost:1080 pulsys@catalog-indexer-qa2
  ```
  Once the tunnel is open [you can see the mail that has been sent on indexer1 here]( http://localhost:1082/) and [indexer2 here]( http://localhost:1085/)

## Testing

### Run Tests

1. Start all the servers/set up database/seed index
   ```
   bundle exec rake servers:start
   ```
   *Note: You can stop everything with `rake servers:stop`

1. initialize the browse lists
  [see instructions](#building-the-browse-lists)

1. Run the all the tests
    ```
    bundle exec rake spec
    ```

1. To run just the rspec tests
   ```
   bundle exec rspec spec
   ```

1. To run just the javascript tests
   ```
   yarn test
   ```

#### To run a specific test
  1. Run steps one and two above
  1. run the individual test
      ```bash
      bundle exec rake spec SPEC=path/to/your_spec.rb:linenumber
      ```

#### Running system specs in the browser

   ```bash
   RUN_IN_BROWSER=true bundle exec rspec spec/system
   ```

The browser will only display for system specs with `js: true`.

#### Running javascript unit tests

`$ yarn install`
`$ yarn test`

##### Debugging jest tests

1. Place a `debugger;` line in your javascript
1. Open up Chrome and type in the address bar: chrome://inspect
1. Click on "Open dedicated DevTools for Node"
1. Back in terminal run `yarn test:debug [path_to_test]` (This has been added to
   package.json)

#### Run erblint
* [erblint](https://github.com/Shopify/erb-lint)
* `bundle exec erblint --lint-all`

#### Running rubocop

```
bundle exec rubocop
```

#### Running reek

```
bundle exec reek app
```

#### Running stylelint

```
yarn stylelint "**/*.scss"
```

#### Run lighthouse from the command line
This command runs a rails server, so you will need to stop any rails server that is already running locally before running the commands below.

```
bundle exec rake servers:start # if you have not yet started the servers
npm install -g @lhci/cli@0.14.x
lhci autorun
```

You can safely ignore the message "GitHub token is not set" --
this is for an integration that we don't currently use. 

It will tell you if you've passed the assertion(s) specified
in `lighthouserc.js`.  It will also give you a URL where you
can see the complete lighthouse results.

#### Running CodeQL locally

If you get a CodeQL warning on your branch, you may wish to run
CodeQL locally to learn more about the issue.

```
brew install codeql
codeql database create orangelight-codeql --language=ruby # creates a gitignored folder for codeql to do its work
codeql database analyze orangelight-codeql --format=csv --output=codeql_results.csv --download codeql/ruby-queries
```

Your results will then be available in the file codeql_results.csv.

#### Building the browse lists
```ruby
RAILS_ENV=test bundle exec rake browse:all browse:load_all
```

#### Refreshing the fixtures
```
bundle exec rake pulsearch:solr:deindex pulsearch:solr:index
```

### Adding a fixture to the test/dev index

Use an example.xml marc record. Start bibdata in the dev environment. Use the bibdata solr url from lando and run:
`bundle exec traject -c marc_to_solr/lib/traject_config.rb path-to-xml/example.xml -u http://localhost:<solr-port-number>/solr/name-of-local-solr-index -w Traject::JsonWriter` This will print a JSON. Copy the JSON and add it to the bottom of `spec/fixtures/current_fixtures.json`. Note that file
contains a list so you have to make sure you add a comma to the end of the last
record and keep the closing bracket at the end of the file. Then run `rake pulsearch:solr:index` for both the dev and the test environment, as specified above.

## Update Solr configuration

Run the following command to update pull in Solr configuration updates from the pul_solr repo:

```bash
bundle exec rake pulsearch:solr:update
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

## Local development with browse lists

To start up a copy of the project with a solr index of fixture data
```bash
bundle exec rake servers:start
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

For more information, see [requests dev hints](docs/requests/dev_hints.md).

You will need a working local copy of [Bibdata](https://github.com/pulibrary/bibdata).
Start the Bibdata server, and then set the ```bidata_base``` value in OrangeLight's `config/requests.yml` file to the local URL where Bibdata is running (e.g., `http://localhost:{port}`) or use the `BIBDATA_BASE` environment variable.

## Development Mailcatcher

   * run mail catcher
     run once
     ```
     gem install mailcatcher
     ```
     run every time
     ```
     bundle exec sidekiq -q default -q mailers
     mailcatcher
     ```

     [you can see the mail that has been sent here]( http://localhost:1080/)

## Update config/hosts.dat from private repo

1. Go to https://github.com/PrincetonUniversityLibrary/ezproxy_conf/blob/main/shim/hosts.dat
  - If you don't have access to this private repo, speak to others on the team about getting access
1. Click "Raw". This should give you a url that looks something like `https://raw.githubusercontent.com/PrincetonUniversityLibrary/ezproxy_conf/main/shim/hosts.dat?token=MY_LONG_TOKEN`
1. Copy the url, and set it to a variable on the command line
```bash
MY_URL=the url you copied above
```
1. Copy the latest version of the remote file to the local file
```bash
curl $MY_URL -o config/hosts.dat
```
1. Optionally, alphabetize the file using your local editor

## Announcement messages

1. To see the current announcement message and feature status, run 
```bash
bundle exec rake announcement:show
```
1. To set a new announcement message, run
```bash
bundle exec rake announcement:set\["My message in a string. Must escape quotes."\]
```
1. To toggle announcements on and off, sign in and go to /features and toggle message display.

## Git Hook

Changes need to be made in 'simple-git-hooks':

1. Make the change in [package.json](https://github.com/pulibrary/allsearch_frontend/blob/main/package.json)
```
"simple-git-hooks": {
    "pre-commit": "yarn lint-staged"
  },
  "lint-staged": {
    "*.js": [
      "prettier --write",
      "eslint"
    ]
  }
  ```
2. Run `yarn simple-git-hooks` to reconfigure the settings.

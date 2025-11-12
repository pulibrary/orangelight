# Remove jquery
Date: 2025-11-11

## Status
Accepted

## Context
Orangelight has included jQuery since its initial commit.  jQuery has helped
us maintain the application despite cross-browser compatibility issues.  Today, we face many fewer compatibility issues.

## Decision
Remove jquery as a dependency.  Instead, use vanilla javascript whenever possible.  In cases where this is not possible, use Vue.

## Consequences

* One less dependency for our project
* Reduced reliance on the sprockets assets pipeline, which we currently use to package jQuery
* Reduced javascript bundle size (see "a note on performance" below)
* Increased reliance on web standards and vanilla javascript as documented in [MDN web docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

## A note on performance
We have a priority of front-end performance in the catalog.  The
jQuery library by itself makes up 85K of the 245K uncompressed
sprockets javascript bundle.  This javascript is not deferred,
so it blocks the browser from rendering the page until it is
downloaded and executed.

Removing jQuery will therefore represent a modest improvement in
performance for users with slow connections and/or slow CPUs.

The 85K size was determined by:
1. `echo "//= link just-jquery.js" >> app/assets/config/manifest.js`
1. `echo "//= require jquery3" > app/assets/javascripts/just-jquery.js`
1. `SECRET_KEY_BASE=fake RAILS_ENV=production be rake assets:clobber assets:precompile`
1. `ls -lh public/assets/(application|just-jquery)*.js`

## Further reading

* [Blog post from Github Engineering on removing Jquery](https://github.blog/engineering/engineering-principles/removing-jquery-from-github-frontend/)

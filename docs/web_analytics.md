## Web Analytics for the Catalog
The current tool utilized for web analytics is [umami](https://docs.umami.is/docs). PUL's installation runs locally at [analytics.lib.princeton.edu](https://analytics.lib.princeton.edu). 

## General Traffic
[Google Tag Manager](https://tagmanager.google.com/#/container/accounts/6231204242/containers/185275726/workspaces/23) is currently used to [inject](https://github.com/pulibrary/orangelight/pull/5188/changes) custom html required to stream data to umami. The umami landing page for the catalog is available [here](https://analytics.lib.princeton.edu/teams/d29eea2b-47ca-453b-b998-019911abdeb4/websites/ee910b04-8b3e-40ed-8fb1-09b28752fe48). 



## Events
At present two [events(https://analytics.lib.princeton.edu/teams/d29eea2b-47ca-453b-b998-019911abdeb4/websites/ee910b04-8b3e-40ed-8fb1-09b28752fe48/events)] are configured for tracking. 

1. Outbound Links
2. Facets Selected

To navigate to events you need to do the following: 

1. Select "Events" under "Traffic" in the main left hand side menu.
2. If you want to view the individual data points you need to then select "properties".
3. On the properties screen you can select the event type and the property type you want to view. 

## Searches
Search values for the catalog are also being logged via umami. They are being recorded in umami's database and then streamed to [Grafana](https://grafana-nomad.lib.princeton.edu/dashboards) for reporting via a [custom dashboard](https://grafana-nomad.lib.princeton.edu/d/dexrthbr7mt4wb/top-queries?from=now-1h&to=now&timezone=browser). Two variations are displayed:

1. Individual search terms.
2. Search terms recorded for an individual session. These are seperated by a "comma" in the display. You need to scroll to the dashboard homepage to see searches by session. 
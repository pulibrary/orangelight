# Test Plan
Orangelight has good coverage by automated tests, but there may be some scenarios in
which manual tests may also be necessary.  Below are the steps to test important
workflows in this application manually.

## Basic Search

|Step|Action|Expected result|
|---|---|---|
|1|Go to [the application](https://catalog-staging.princeton.edu/)|The application has a Search box at the top of the page|
|2|Enter `plasticity` in the search box and press the enter key or click the search button|You are taken to a search results page with a number of matching results|
|3|Click "Catalog" in the header to return to the home page|
|4|Select `Author (keyword)` from the dropdown in the Search bar|
|5|Enter `john d clark` in the search box and press the enter key or click the search button|You are taken to a search results page with a number of matching results|
|6|Remove the selected facet value for `Author/Creator` by clicking the `X` button|You should see all a search results page with all results|

## Record Page

|Step|Action|Expected result|
|---|---|---|
|1|Go to the Record page for [an item](https://catalog-staging.princeton.edu/catalog/99111163333506421)|The application displays a page with details on the book It's all Greek|
|2|There should be a section with author, format, language, etc. for the item|
|3|There should be a section with the holding location, call number, availability information, and a request button|
|4|Click the `Where to find it` button|A modal should pop up with a map of firestone with a marker indicating the shelving location of the item|
|5|Click the `X` button to close the modal|You should return to the record page|
|6|There should be a section with detailed information, including subjects, a summary, and a link to the staff view|
|7|Click the `Staff view` link|The detailed MARC record should be displayed|

## Request Form

|Step|Action|Expected result|
|---|---|---|
|1|Without an active session, go to the Record page for [an item](https://catalog-staging.princeton.edu/catalog/99111163333506421)|The application displays a page with details on the book It's all Greek|
|2|Click on the `Request` button|You should be redirected to the login page|
|3|Click on the `Log in with netID` button and follow the CAS prompts|The request form should display with the item selected and the delivery options unselected. The `Request this Item` button should be disabled|
|4|Click the `Physical Item Delivery` radio element|The Pick-up location should display Firestone Library and the `Request this Item` button should be enabled|
|5|Click the checkbox in the `Select` column|The `Request this Item` button should be disabled|
|6|Click the checkbox in the `Select` column to re-enable the `Request this Item` button|
|7|Click the `Request this Item` button to submit the request|A success notification with the text `Item has been requested for pick-up` should appear|

## Advanced Search

|Step|Action|Expected result|
|---|---|---|
|1|From the [home page](https://catalog-staging.princeton.edu/) click on the advanced search link next to the basic search box|The application should navigate to the advanced search form|
|2|In the first text input enter `cats` and click the `Search` button|Search results with approximately 45,000 items should display|
|3|Click the `Edit search` button|You should return to the advanced search form|
|4|In the second text input next to `Author/Creator` enter `warhol` and click the `Search` button|Search results with about 9 items should display|
|5|Click the `Edit search` button|You should return to the advanced search form|
|6|Select `French` from the `Language` dropdown and click the `Search` button|Search results with both an Author/Creator and Language selected facets and fewer items should display|
|7|Click the `Edit search` button|You should return to the advanced search form|
|8|Enter the years `1950` and `1960` in the text inputs for `Publication year` and click the `Search` button|A search results page should render that says there are no results found for your search|

## Browse Lists

|Step|Action|Expected result|
|---|---|---|
|1|Go to the subject [browse list](https://catalog-staging.princeton.edu/browse/subjects?search_field=browse_subject&q=cats)|The application should display a list of subjects|
|2|Use the drop-down menu to change the display to `10 per page`|The displayed list should only have 10 results|
|3|Use the `Previous` and `Next` buttons to navigate through the browse list|The browse list should navigate through the list of subjects|
|4|Click on the subject heading for `Cats`|A search results page should display with results|
|5|Go to a [record page](https://catalog-staging.princeton.edu/catalog/99111163333506421)|
|6|Click on the `Browse` link next to the subject `English language-Foreign elements-Greek`|You should see a list of subjects with a type of LC subject heading|
|7|Click on the link for the highlighted subject|You should see a search results page with items related to that subject|

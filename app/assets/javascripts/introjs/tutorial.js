
function startIntro(){
  var intro = introJs();
    intro.setOptions({
      steps: [
        {
          element: '#search_field',
          intro: 'The catalog can be searched in a variety of ways. Title starts with retrieves an exact title.'
        },
        {
          element: '#facet-panel-collapse',
          intro: 'Search limits restrict your search and can be applied before or after your enter your terms.',
          position: 'right'
        },
        {
          element: '#q',
          intro: 'Enter search terms here.',
        }
      ],
      showStepNumbers: false,
      skipLabel: 'Cancel',
      doneLabel: 'Continue'
    });
    intro.start().oncomplete(function() {
      window.location.href = '/catalog?introjs=results&search_field=all_fields&q=Egypt+foreign+relations';
    });
}

function resultsPage(){
  var intro = introJs();
    intro.setOptions({
      steps: [
        {
          element: '.facet_limit.blacklight-access_facet',
          intro: 'Access limits search by physical (In the Library) or electronic access (Online).',
          position: 'right'
        },
        {
          element: '.facet_limit.blacklight-location',
          intro: 'Library allows you to restrict your search to items held at a specific Princeton library.',
          position: 'right'
        },
        {
          element: '.facet_limit.blacklight-format',
          intro: 'Format limits by item type and can be useful for finding journal or video titles.',
          position: 'right'
        },
        {
          element: '.document.document-position-0',
          intro: 'From here you can see an item\'s availability, location and call number. A click on the blue pin opens a map with directions to an item’s precise location.',
          position: 'left'
        },
        {
          element: '.search-widgets',
          intro: 'You can change the list’s sort options, the number of items displayed per page, or bookmark a collection of items.',
          position: 'bottom'
        },
        {
          element: 'form.bookmark_toggle',
          intro: 'Items may also be bookmarked individually.',
          position: 'bottom'
        },
        {
          element: '#bookmarks_nav',
          intro: 'A collection of items can be e-mailed from the Bookmarks page or saved for future use by logging in to Your Account.',
          position: 'bottom'
        },
      ],
      showStepNumbers: false,
      skipLabel: 'Cancel',
      doneLabel: 'Continue'
    });

    intro.start().oncomplete(function() {
      window.location.href = '/catalog/7185628?introjs=record';
    });
}

function recordPage(){
  var intro = introJs();
    intro.setOptions({
      steps: [
        {
          element: '#availability',
          intro: 'The information of each item displays in three columns. The right column contains availability information.',
          position: 'left'
        },
        {
          element: '.location--holding',
          intro: 'The Copies in Library box contains item location, call number, and a link to other related items (Browse related items). If an item requires a special request for retrieval, that link is also located here.',
          position: 'left'
        },
        {
          element: 'dd.blacklight-author_display',
          intro: 'Authors and subjects are followed by [Browse]. Clicking [Browse] returns the author\'s name situated in an alphabetical list of other names. Clicking on the name returns a result list of other items attributed to that author.',
          position: 'left'
        },
        {
          element: 'dd.blacklight-subject_display',
          intro: 'Click on any part of the subject heading to run a broad or more narrow subject search.',
          position: 'left'
        },
        {
          element: 'ul.navbar-right',
          intro: 'Here you can cite, export, or bookmark the item.',
          position: 'left'
        },
        {
          element: 'button.btn-account',
          intro: 'Log in to Your Account to view and renew your currently checked out items.',
          position: 'left'
        },
        {
          element: '.advanced_search',
          intro: 'Advanced search offers a variety of search combinations, with the option to filter by multiple languages.',
          position: 'bottom'
        },
      ],
      showStepNumbers: false,
      skipLabel: 'Cancel'
    });
    intro.start();
}

$(document).ready(function() {
  if (RegExp('introjs=results', 'gi').test(window.location.search)) {
    resultsPage();
  }
  if (RegExp('introjs=record', 'gi').test(window.location.search)) {
    recordPage();
  }
});

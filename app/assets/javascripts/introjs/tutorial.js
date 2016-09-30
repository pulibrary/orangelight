
function startIntro(){
  var intro = introJs();
    intro.setOptions({
      steps: [
        {
          element: '#search_field',
          intro: 'The catalog can be searched in a variety of ways by clicking the dropdown box. <strong>Title starts with</strong> retrieves an exact title.'
        },
        {
          element: '#facet-panel-collapse',
          intro: 'Search limits restrict your search and can be applied before or after you enter your terms.',
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
          intro: '<strong>Access</strong> limits your search results by physical <strong>(In the Library)</strong> or electronic access <strong>(Online)</strong>.',
          position: 'right'
        },
        {
          element: '.facet_limit.blacklight-location',
          intro: '<strong>Library</strong> allows you to restrict your search to items held at a specific Princeton library.',
          position: 'right'
        },
        {
          element: '.facet_limit.blacklight-format',
          intro: '<strong>Format</strong> limits by item type and can be useful for finding journal or video titles.',
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
          intro: 'A collection of items can be e-mailed from the <strong>Bookmarks</strong> page or saved for future use by logging in to <strong>Your Account</strong>.',
          position: 'bottom'
        },
      ],
      showStepNumbers: false,
      skipLabel: 'Cancel',
      doneLabel: 'Continue'
    });

    intro.start().oncomplete(function() {
      window.location.href = '/catalog/5787995?introjs=record';
    });
}

function recordPage(){
  var intro = introJs();
    intro.setOptions({
      steps: [
        {
          element: '#availability',
          intro: 'Information about each item displays in three columns. The right column contains availability information.',
          position: 'left'
        },
        {
          element: '.location--holding',
          intro: 'The <strong>Copies in Library</strong> box contains item location, call number, and a link to other related items <strong>(Browse related items)</strong>. If an item requires a special request for retrieval, that link is also located here.',
          position: 'left'
        },
        {
          element: 'dd.blacklight-author_display',
          intro: 'Authors and subjects are followed by <strong>[Browse]</strong>. Clicking <strong>[Browse]</strong> returns the author\'s name situated in an alphabetical list of other names. Clicking on the name returns a result list of other items attributed to that author.',
          position: 'left'
        },
        {
          element: 'dd.blacklight-subject_display',
          intro: 'Click on any part of the subject heading to run a broader or narrower subject search.',
          position: 'left'
        },
        {
          element: 'ul.navbar-right',
          intro: 'Here you can cite, export, or bookmark the item.',
          position: 'left'
        },
        {
          element: 'button.btn-account',
          intro: 'Log in to <strong>Your Account</strong> to view and renew your currently checked out items.',
          position: 'left'
        },
        {
          element: '.advanced_search',
          intro: '<strong>Advanced search</strong> offers a variety of search combinations, with the option to filter by multiple languages.',
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

export default class BookmarksSort {
  constructor() {
    this.update_sort_text();
  }

  update_sort_text() {
    if (!this.on_bookmarks_page()) {
      const sort = document.querySelector('#sort-dropdown').childNodes[1];
      if (sort.textContent.includes('recently bookmarked')) {
        sort.textContent = '\n      Sort by  \n  relevance';
      }
    }
  }

  on_bookmarks_page() {
    return window.location.pathname.includes('/bookmarks');
  }
}

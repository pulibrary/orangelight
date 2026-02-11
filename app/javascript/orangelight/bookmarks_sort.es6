export default class BookmarksSort {
  constructor() {
    this.update_sort_text();
  }

  update_sort_text() {
    const dropdown = document.querySelector('#sort-dropdown');
    if (this.on_catalog_search_page() && dropdown) {
      const sort = dropdown.childNodes[1];
      if (sort.textContent.includes('recently bookmarked')) {
        sort.textContent = '\n      Sort by  \n  relevance';
      }
    }
  }

  on_catalog_search_page() {
    return window.location.pathname.includes('/catalog');
  }
}

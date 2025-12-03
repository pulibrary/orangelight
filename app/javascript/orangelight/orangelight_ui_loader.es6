import BookCoverManager from '../orangelight/book_covers.es6';
import { FiggyManifestManager } from '../orangelight/figgy_manifest_manager';
import GoogleBooksSnippets from '../orangelight/google_books_snippets.es6';
import RelatedRecordsDisplayer from '../orangelight/related_records.es6';
import DisplayMoreFieldComponent from '../../components/display_more_field_component.es6';
import { handleBtnKeyDown } from './accessible_facets';
import { orangelight } from './orangelight.es6';
import AlertManager from './alert_manager';

export default class OrangelightUiLoader {
  run() {
    this.setup_linked_records();
    this.setup_show_more_fields();
    this.setup_viewers();
    this.setup_book_covers();
    handleBtnKeyDown();
    orangelight();
    globalThis.alertManager = new AlertManager();
  }

  setup_linked_records() {
    const buttons = document.querySelectorAll('.show-more-linked-records');
    if (buttons.length > 0) {
      for (const button of buttons) {
        const fetchData = RelatedRecordsDisplayer.fetchData(
          button.getAttribute('data-linked-records-field'),
          button.getAttribute('data-record-id')
        );
        button.addEventListener('click', (event) => {
          fetchData.then((displayer) => displayer.toggle(event));
        });
      }
    }
  }

  setup_show_more_fields() {
    const buttons = document.querySelectorAll('.btn.show-more');
    if (buttons.length > 0) {
      for (const button of buttons) {
        const displayer = new DisplayMoreFieldComponent();
        button.addEventListener('click', (event) => {
          displayer.toggle(event);
        });
      }
    }
  }

  setup_viewers() {
    const elements = document.querySelectorAll(
      '.document-thumbnail[data-bib-id]'
    );
    if (elements.length > 0) {
      const thumbnails = FiggyManifestManager.buildThumbnailSet(elements);
      thumbnails.render();
    }

    this.#documentViewers().forEach(async (element) => {
      const viewerSet = FiggyManifestManager.buildViewers(element);
      await viewerSet.render();
      const google_books_snippets = new GoogleBooksSnippets();
      if (google_books_snippets.has_figgy_viewer === false)
        google_books_snippets.insert_snippet();
    });
  }

  setup_book_covers() {
    new BookCoverManager();
  }

  #documentViewers() {
    return document.querySelectorAll('.document-viewers');
  }
}

import AvailabilityUpdater from '../orangelight/availability.es6'
import BookCoverManager from '../orangelight/book_covers.es6'
import BookmarkAllManager from '../orangelight/bookmark_all.es6'
import {FiggyManifestManager} from '../orangelight/figgy_manifest_manager'
import GoogleBooksSnippets from '../orangelight/google_books_snippets.es6'
import RelatedRecordsDisplayer from '../orangelight/related_records.es6'
import DisplayMoreFieldComponent from '../../components/display_more_field_component.es6'
import { handleBtnKeyDown } from './accessible_facets'

export default class OrangelightUiLoader {
  run() {
    this.setup_availability()
    this.setup_linked_records()
    this.setup_show_more_fields()
    this.setup_modal_focus()
    this.setup_viewers()
    this.setup_book_covers()
    this.setup_bookmark_all()
    handleBtnKeyDown()
  }

  setup_modal_focus() {
    $("body").on("shown.bs.modal", (event) => {
      $(event.target).find('input[type!="hidden"]').first().focus();
    })
  }

  setup_availability() {
    let au2
    au2 = new AvailabilityUpdater
    au2.request_availability(true);
    au2.scsb_search_availability();
  }

  setup_linked_records() {
    const buttons = document.querySelectorAll('.show-more-linked-records');
    if (buttons.length > 0) {
      for (let button of buttons) {
        const fetchData = RelatedRecordsDisplayer.fetchData(
          button.getAttribute('data-linked-records-field'),
          button.getAttribute('data-record-id'));
        button.addEventListener('click', (event) => {
          fetchData.then(displayer => displayer.toggle(event))
        });
      };
    }
  }

  setup_show_more_fields() {
    const buttons = document.querySelectorAll('.btn.show-more');
    if (buttons.length > 0) {
      for (let button of buttons) {
        const displayer = new DisplayMoreFieldComponent();
        button.addEventListener('click', (event) => { displayer.toggle(event) });
      }
    }
  }

  setup_viewers() {
    const $elements = $(".document-thumbnail[data-bib-id]")
    if($elements.length > 0) {
      const thumbnails = FiggyManifestManager.buildThumbnailSet($elements)
      thumbnails.render()
    }
    const $monogramIds = $("p[data-monogram-id]")
    if($monogramIds.length > 0 ) {
      const monograms = FiggyManifestManager.buildMonogramThumbnails($monogramIds)
      monograms.renderMonogram()
    }

    $(".document-viewers").each(async (_, element) => {
      const viewerSet = FiggyManifestManager.buildViewers(element)
      await viewerSet.render()
      const google_books_snippets = new GoogleBooksSnippets
      if(google_books_snippets.has_figgy_viewer === false)
        google_books_snippets.insert_snippet()
    })
  }

  setup_book_covers() {
    new BookCoverManager
  }

  setup_bookmark_all() {
    new BookmarkAllManager
  }
}

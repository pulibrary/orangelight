import AvailabilityUpdater from '../orangelight/availability'
import FiggyManifestManager from '../orangelight/figgy_manifest_manager'
import GoogleBooksSnippets from '../orangelight/google_books_snippets'
import RelatedRecordsDisplayer from '../orangelight/related_records'
import { handleBtnKeyDown } from './accessible_facets'

export default class OrangelightUiLoader {
  run() {
    this.setup_availability()
    this.setup_linked_records()
    this.setup_modal_focus()
    this.setup_viewers()
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
    const buttons = document.getElementsByClassName('show-more-linked-records');
    for (let i=0; i < buttons.length; i++) {
      const fetchData = RelatedRecordsDisplayer.fetchData(
        buttons[i].getAttribute('data-linked-records-field'),
        buttons[i].getAttribute('data-linked-records-record-id'));
      buttons[i].addEventListener('click', (event) => {
        fetchData.then(displayer => displayer.toggle(event))
      });
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
}

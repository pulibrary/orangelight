import AvailabilityUpdater from '../orangelight/availability'
import FiggyManifestManager from '../orangelight/figgy_manifest_manager'
import GoogleBooksSnippets from '../orangelight/google_books_snippets'

export default class OrangelightUiLoader {
  run() {
    this.setup_availability()
    this.setup_modal_focus()
    this.setup_viewers()
  }

  setup_modal_focus() {
    $("body").on("shown.bs.modal", (event) => {
      $(event.target).find('input[type!="hidden"]').first().focus();
    })
  }

  setup_availability() {
    let au2 = new AvailabilityUpdater
    au2.request_availability();
    au2.scsb_search_availability();
  }

  setup_viewers() {
    const $elements = $(".document-thumbnail[data-bib-id]")
    const thumbnails = FiggyManifestManager.buildThumbnailSet($elements)
    thumbnails.render()
    const $monogramIds = $("p[data-monogram-id]")
    const monograms = FiggyManifestManager.buildMonogramThumbnails($monogramIds)
    monograms.renderMonogram()

    $(".document-viewers").each((_, element) => {
      const viewerSet = FiggyManifestManager.buildViewers(element)
      // await here
      viewerSet.render()
      // check to see if the viewer was populated. If not, add in the google books
      // wizard
      // new GoogleBooksSnippets
      const google_books_snippets = new GoogleBooksSnippets
      window.google_books_snippets = google_books_snippets
      google_books_snippets.insert_snippet()
    })
  }
}

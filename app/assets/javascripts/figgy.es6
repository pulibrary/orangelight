window.jQuery(document).ready(() => {
  const $elements = window.jQuery(".document-thumbnail[data-bib-id]")
  const thumbnails = FiggyManifestManager.buildThumbnailSet($elements)
  thumbnails.render()
  const $monogramIds = window.jQuery("p[data-monogram-id]")
  const monograms = FiggyManifestManager.buildMonogramThumbnails($monogramIds)
  monograms.renderMonogram()

  window.jQuery(".document-viewers").each((idx, element) => {
    const viewerSet = FiggyManifestManager.buildViewers(element)
    // await here
    viewerSet.render()
    // check to see if the viewer was populated. If not, add in the google books
    // wizard
    // new GoogleBooksSnippets
  })
})

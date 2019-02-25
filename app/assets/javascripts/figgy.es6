
window.jQuery(document).ready(() => {
  const $elements = window.jQuery(".document-thumbnail[data-bib-id]")
  const thumbnails = FiggyManifestManager.buildThumbnailSet($elements)
  thumbnails.render()

  window.jQuery(".document-viewers").each((idx, element) => {
     const viewerSet = FiggyManifestManager.buildViewers(element)
     viewerSet.render()
  })
})

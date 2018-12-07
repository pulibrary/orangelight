
window.jQuery(document).ready(() => {

  window.jQuery(".document-thumbnail[data-bib-id]").each((idx, element) => {
    const thumbnail = FiggyManifestManager.buildThumbnail(element)
    thumbnail.render()
  })

  window.jQuery(".document-viewers").each((idx, element) => {
     const viewerSet = FiggyManifestManager.buildViewers(element)
     viewerSet.render()
  })
})

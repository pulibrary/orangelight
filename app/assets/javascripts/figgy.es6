
window.jQuery(document).ready(() => {

  window.jQuery(".document-thumbnail[data-bib-id]").each((idx, element) => {
    const thumbnail = FiggyManifestManager.buildThumbnail(element)
    thumbnail.render()
  })

  window.jQuery("#document div:first").each((idx, element) => {
    if (window.jQuery("#arks_length").length < 1) {
      const viewerSet = FiggyManifestManager.buildViewers(element)
      viewerSet.render()
    }
  })
})


window.jQuery(document).ready(() => {

  window.jQuery(".document-thumbnail[data-bib-id]").each((idx, element) => {
    const thumbnail = FiggyThumbnailManager.buildThumbnail(element)
    thumbnail.render()
  })
})

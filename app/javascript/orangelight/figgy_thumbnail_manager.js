
import loadResourcesByBibId from './load-resources-by-bib-id'

class FiggyThumbnail {
  constructor(element, query, variables, jQuery) {
    this.element = element
    this.query = query
    this.variables = variables
    this.jQuery = jQuery
  }

  async fetchResources() {
    const data = await this.query.call(this, this.variables)
    if (!data) {
      return null;
    }

    const resources = data.resourcesByBibid
    return resources
  }

  async getResource() {
    this.resources = await this.fetchResources()
    if (!this.resources || this.resources.length < 1) {
      return null
    }
    return this.resources[0]
  }

  async getThumbnail() {
    const resource = await this.getResource()
    if (!resource) {
      return null
    }
    return resource.thumbnail
  }

  async constructThumbnailElement() {
    const thumbnail = await this.getThumbnail()
    if (!thumbnail) {
      return null
    }

    const $element = this.jQuery(`<img alt="" src="${thumbnail.thumbnailUrl}">`)
    return $element
  }

  async render() {
    const $element = this.jQuery(this.element)
    const $thumbnailElement = await this.constructThumbnailElement()
    if (!$thumbnailElement) {
      return
    }

    $element.empty()
    $element.append($thumbnailElement)
  }
}

class FiggyThumbnailManager {

  static buildThumbnail(element) {
    const $element = window.jQuery(element)
    const bibId = $element.data('bib-id')
    return new FiggyThumbnail(element, loadResourcesByBibId, bibId.toString(), window.jQuery)
  }
}

export default FiggyThumbnailManager

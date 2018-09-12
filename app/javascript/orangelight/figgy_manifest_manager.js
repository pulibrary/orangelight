
import loadResourcesByBibId from './load-resources-by-bib-id'

class FiggyViewer {

  constructor(idx, manifestUrl) {
    this.idx = idx
    this.manifestUrl = manifestUrl
  }

  getAvailabilityElement() {
    let elements = document.querySelectorAll('#availability > div.location--panel.location--online > div > div.panel-body > div')
    if (elements.length < 1) {
      elements = document.querySelectorAll('#availability > div.location--panel.location--online > div > div.panel-body > div > ul > div.electronic-access')
    }
    // This assumes that the first element is the link
    const element = elements[this.idx]
    return element
  }

  getArkLinkElement() {
    // If there is only one electronic access link, it's structure using a <div> rather than <ul>
    const availabilityElement = this.getAvailabilityElement()

    if (!availabilityElement) {
      return null
    }

    let element = availabilityElement.querySelector('div > a')
    if (!element) {
      element = availabilityElement.querySelector('li > a')
    }
    return element
  }

  updateArkLinkElement() {
    const arkLinkElement = this.getArkLinkElement()
    if (!arkLinkElement) {
      return
    }

    arkLinkElement.href = "#view"
    arkLinkElement.removeAttribute("target")
  }

  getViewerElement() {
    const viewerElement = this.idx == 0 ? document.getElementById("view") : document.getElementById(`view_${this.idx}`)
    return viewerElement
  }

  constructIFrame() {
    const iframeElement = document.createElement("iframe")
    iframeElement.setAttribute("allowFullScreen", "true")
    iframeElement.id = this.idx == 0 ? "iframe" : `iframe_${this.idx}`

    // This needs to be retrieved using Global
    const figgyUrl = window.Global.figgy.url
    const src = `${figgyUrl}/uv#?manifest=${this.manifestUrl}`
    iframeElement.src = src

    return iframeElement
  }

  async render() {
    const iFrameElement = await this.constructIFrame()
    if (!iFrameElement) {
      return null
    }
    this.updateArkLinkElement()

    const viewerElement = this.getViewerElement()
    viewerElement.appendChild(iFrameElement)
  }
}

class FiggyViewerSet {
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

  async getManifestUrls() {
    const resources = await this.fetchResources()
    if (!resources) {
      return []
    }

    const manifestUrls = resources.map((resource) => {
      return resource.manifestUrl
    })

    return manifestUrls
  }

  getViewerElementByIndex(idx = 0) {
    const viewerElement = idx == 0 ? document.getElementById("view") : document.getElementById(`view_${idx}`)
    return viewerElement
  }

  async render() {
    const manifestUrls = await this.getManifestUrls()

    manifestUrls.forEach((manifestUrl, idx) => {
      const viewer = new FiggyViewer(idx, manifestUrl)
      viewer.render()
    })
  }
}

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

class FiggyManifestManager {

  static buildThumbnail(element) {
    const $element = window.jQuery(element)
    const bibId = $element.data('bib-id')
    return new FiggyThumbnail(element, loadResourcesByBibId, bibId.toString(), window.jQuery)
  }

  // Build multiple viewers
  static buildViewers(element) {
    const $element = window.jQuery(element)
    const id = element.id
    const bibId = id.replace(/doc_/, '')

    return new FiggyViewerSet(element, loadResourcesByBibId, bibId, window.jQuery)
  }
}

export default FiggyManifestManager

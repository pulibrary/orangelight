
import loadResourcesByBibId from './load-resources-by-bib-id'

class FiggyViewer {
  // There may be more than one ARK minted which resolves to the same manifested resource
  constructor(idx, element, manifestUrl, arks) {
    this.idx = idx
    this.element = element
    this.manifestUrl = manifestUrl
    this.arks = arks
  }

  getAvailabilityElement() {
    let elements = document.querySelectorAll('#availability > div.location--panel.location--online > div > div.panel-body > div')
    if (elements.length < 1) {
      elements = document.querySelectorAll('#availability > div.location--panel.location--online > div > div.panel-body > div > ul > div.electronic-access')
    }
    // This assumes that the first element is the link
    const element = elements[0]
    return element
  }

  getArkLinkElement() {
    // If there is only one electronic access link, it's structure using a <div> rather than <ul>
    const availabilityElement = this.getAvailabilityElement()

    if (!availabilityElement) {
      return null
    }

    let elements = availabilityElement.querySelectorAll('div > a')
    if (elements.length < 1) {
      elements = availabilityElement.querySelectorAll('li > a')
    }
    // This assumes that there is a one-to-one mapping between the ARK electronic resource links in the DOM and the UniversalViewer instances
    return elements[this.idx]
  }

  buildViewerId() {
    return this.idx == 0 ? 'view' : `view_${this.idx}`
  }

  updateArkLinkElement() {
    const arkLinkElement = this.getArkLinkElement()
    if (!arkLinkElement) {
      return
    }

    arkLinkElement.href = '#' + this.buildViewerId()
    arkLinkElement.removeAttribute("target")
  }

  constructIFrame() {
    const iframeElement = document.createElement("iframe")
    iframeElement.setAttribute("allowFullScreen", "true")
    iframeElement.id = `iframe-${this.idx + 1}`

    // This needs to be retrieved using Global
    const figgyUrl = window.Global.figgy.url
    const src = `${figgyUrl}/uv/uv#?manifest=${this.manifestUrl}`
    iframeElement.src = src

    return iframeElement
  }

  constructViewerElement() {
    const viewerElement = document.createElement("div")
    viewerElement.setAttribute("class", "intrinsic-container intrinsic-container-16x9")
    viewerElement.id = this.buildViewerId()

    const iFrameElement = this.constructIFrame()
    viewerElement.appendChild(iFrameElement)

    return viewerElement
  }

  async render() {
    const viewerElement = this.constructViewerElement()
    if (!viewerElement) {
      return null
    }

    if (this.arks.length > 0) {
      this.updateArkLinkElement()
    }

    this.element.appendChild(viewerElement)
  }
}

class FiggyViewerSet {
  constructor(element, query, variables, arks, jQuery) {
    this.element = element
    this.query = query
    this.variables = variables
    this.arks = arks
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

    // Filter only for resources with child resources (i. e. non-FileSets) as members
    // This is not performant, and should require a separate GraphQL query
    const filteredResources = resources.filter((resource) => {
      if (!resource['members'])
        return true
      return resource.members.filter((member) => {
        return member.__typename != "FileSet"
      }).length > 0
    })
    if (resources.length > 0 && filteredResources.length < 1)
      return resources.map((resource) => {
        return resource.manifestUrl
      })

    return filteredResources.map((resource) => {
      return resource.manifestUrl
    })
  }

  async render() {
    const manifestUrls = await this.getManifestUrls()

    manifestUrls.forEach((manifestUrl, idx) => {
      const viewer = new FiggyViewer(idx, this.element, manifestUrl, this.arks)
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
    const bibId = $element.data('bib-id')
    const arks = $element.data('arks') || []

    return new FiggyViewerSet(element, loadResourcesByBibId, bibId.toString(), arks, window.jQuery)
  }
}

export default FiggyManifestManager

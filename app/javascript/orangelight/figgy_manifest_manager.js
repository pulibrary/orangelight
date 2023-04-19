import loadResourcesByFiggyIds from './load-resources-by-figgy-ids'
import loadResourcesByOrangelightId from './load-resources-by-orangelight-id'
import loadResourcesByOrangelightIds from './load-resources-by-orangelight-ids'
import { insert_online_link } from './insert_online_link.es6'

class FiggyViewer {
  // There may be more than one ARK minted which resolves to the same manifested resource
  constructor(idx, element, manifestUrl) {
    this.idx = idx
    this.element = element
    this.manifestUrl = manifestUrl
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

  buildViewerId() {
    return this.idx == 0 ? 'viewer-container' : `viewer-container_${this.idx}`
  }

  constructIFrame() {
    const iframeElement = document.createElement("iframe")
    iframeElement.setAttribute("allowFullScreen", "true")
    iframeElement.setAttribute("title", "Digital content viewer")
    iframeElement.id = `iframe-${this.idx + 1}`

    // This needs to be retrieved using Global
    const figgyUrl = window.Global.figgy.url
    const src = `${figgyUrl}/viewer#?manifest=${this.manifestUrl}&config=${figgyUrl}/uv/uv_config.json`
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

    this.element.appendChild(viewerElement)
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
    const resources = data.resourcesByOrangelightId
    return resources
  }

  getManifestUrls(resources) {
    if (!resources) {
      return []
    }

    return resources.map((resource) => {
      return resource.manifestUrl
    })
  }

  isUnauthorizedSeniorThesis(resource) {
    if(resource.notice !== undefined) {
      if(resource.notice){
        const isSeniorThesis = resource.notice.heading.search("Senior Thesis");
        return resource.embed.status == 'unauthorized' && isSeniorThesis
      }
    }
    return false;
  }

  // function for adding thesis request link
  addThesisRequestLinks(resources) {
    let iteration = 0;
    const link = 'https://library.princeton.edu/special-collections/senior-thesis-order-form';
    const target = '_blank';
    resources.forEach((resource) => {
      if(this.isUnauthorizedSeniorThesis(resource)) {
        const content = (link, target) => {
          return `<a href="${link}" target="${target}">Request a copy of ${resource.label}</a><p>Princeton community has access to this thesis on campus or VPN.</p>`
        }
        insert_online_link(link, `thesis_request_link_${iteration}`, content);
        iteration++;
      }
    })
  }

  async render() {
    let resources = await this.fetchResources()
    this.addThesisRequestLinks(resources)
    const filteredResources = resources.filter((resource) => {
      return !this.isUnauthorizedSeniorThesis(resource)
    })
    const manifestUrls = await this.getManifestUrls(filteredResources)
    manifestUrls.forEach((manifestUrl, idx) => {
      const viewer = new FiggyViewer(idx, this.element, manifestUrl)
      viewer.render()
    })
  }
}

// Queries for resources using multiple bib. IDs
class FiggyThumbnailSet {

  constructor(elements, query, jQuery) {
    this.elements = elements
    this.$elements = jQuery(elements)
    this.query = query
    this.jQuery = jQuery
  }

  async fetchResources() {
    this.bibIds = this.$elements.map((idx, element) => this.jQuery(element).data('bib-id').toString())

    const variables = { bibIds: this.bibIds.toArray() }
    this.thumbnails = {}
    const data = await this.query.call(this, variables.bibIds)
    if (!data) {
      return null;
    }

    const resources = data.resourcesByOrangelightIds
    this.resources = resources

    // Cache the thumbnail URLs
    for (let resource of this.resources) {
      const orangelightId = resource.orangelightId
      this.thumbnails[orangelightId] = resource.thumbnail
    }
    return this.resources
  }

  async fetchMonogramResources() {
    this.ids = this.$elements.map((idx, element) => this.jQuery(element).data('monogram-id').toString())
    const variables = { ids: this.ids.toArray() }
    this.thumbnails = {}
    const data = await this.query.call(this, variables.ids)
    if (!data) {
      return null;
    }

    const resources = data.resourcesByFiggyIds
    this.resources = resources

    // Cache the thumbnail URLs
    for (let resource of this.resources) {
      const id = resource.id
      this.thumbnails[id] = resource.thumbnail
    }
    return this.resources
  }

  constructThumbnailElement(bibId) {
    const thumbnail = this.thumbnails[bibId]

    if (!thumbnail) {
      return null
    }

    const $element = this.jQuery(`<img alt="" src="${thumbnail.iiifServiceUrl}/square/225,/0/default.jpg">`)
    return $element
  }

  constructMonogramThumbnailElement(figgyId) {
    const thumbnail = this.thumbnails[figgyId]
    if (!thumbnail) {
      return null
    }

    const $element = this.jQuery(`<img alt="" src="${thumbnail.iiifServiceUrl}/full/225,/0/default.jpg">`)
    return $element
  }

  async render() {
    await this.fetchResources()
    this.$elements.map((idx, element) => {
      const $element = this.jQuery(element)
      const bibId = $element.data('bib-id')
      const $thumbnailElement = this.constructThumbnailElement(bibId)

      if (!$thumbnailElement) {
        return
      }
      $element.empty()
      $element.addClass('has-viewer-link')
      $element.wrap('<a href="#viewer-container"></a>').append('<span class="sr-only">Go to viewer</span>')
      $element.append($thumbnailElement)
    })
  }

  async renderMonogram() {
    await this.fetchMonogramResources()
    this.$elements.map((idx, element) => {
      const $element = this.jQuery(element)
      const monogramId = $element.data('monogram-id')
      const $thumbnailElement = this.constructMonogramThumbnailElement(monogramId)
      if (!$thumbnailElement) {
        return
      }
      $element.after($thumbnailElement)
    })
  }
}

class FiggyManifestManager {

  static buildThumbnailSet($elements) {
    return new FiggyThumbnailSet($elements, loadResourcesByOrangelightIds, window.jQuery)
  }
  // See: https://github.com/pulibrary/orangelight/issues/2967
  static buildMonogramThumbnails($monogramIds) {
    return new FiggyThumbnailSet($monogramIds, loadResourcesByFiggyIds, window.jQuery)
  }

  // Build multiple viewers
  static buildViewers(element) {
    const $element = window.jQuery(element)
    const bibId = $element.data('bib-id')
    return new FiggyViewerSet(element, loadResourcesByOrangelightId, bibId.toString(), window.jQuery)
  }
}

export {FiggyManifestManager, FiggyViewer, FiggyViewerSet};

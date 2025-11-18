import { Option } from './option.es6';

// Checks if the current path is a valid record page (catalog/ID)
// Matches catalog/ followed by:
// - starts with 99 and ends with 3506421 (Alma)
// - dsp + 1 or more alphanumeric
// - UUID (8-4-4-4-12)
// - SCSB- + digits
function isRecordPagePath() {
  const path = window.location.pathname;
  const regex =
    /^\/catalog\/(\d{14,}|99\w+3506421|dsp[\w]+|[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}|SCSB-\d+)$/;
  return regex.test(path);
}

// Helper to wrap thumbnail element with viewer link and accessibility span
function wrapWithViewerLink(element) {
  element.classList.add('has-viewer-link');
  const link = document.createElement('a');
  link.setAttribute('href', '#viewer-container');
  element.parentNode.appendChild(link);
  link.appendChild(element);

  const linkText = document.createElement('span');
  linkText.classList.add('visually-hidden');
  linkText.textContent = 'Go to viewer';
  element.appendChild(linkText);
}
import loadResourcesByOrangelightId from './load-resources-by-orangelight-id';
import loadResourcesByOrangelightIds from './load-resources-by-orangelight-ids';
import { insert_online_link } from './insert_online_link.es6';

class FiggyViewer {
  // There may be more than one ARK minted which resolves to the same manifested resource
  constructor(idx, element, manifestUrl) {
    this.idx = idx;
    this.element = element;
    this.manifestUrl = manifestUrl;
  }

  buildViewerId() {
    return this.idx == 0 ? 'viewer-container' : `viewer-container_${this.idx}`;
  }

  constructIFrame() {
    const iframeElement = document.createElement('iframe');
    iframeElement.setAttribute('allowFullScreen', 'true');
    iframeElement.setAttribute('title', 'Digital content viewer');
    iframeElement.id = `iframe-${this.idx + 1}`;

    // This needs to be retrieved using Global
    const figgyUrl = window.Global.figgy.url;
    const src = `${figgyUrl}/viewer#?manifest=${this.manifestUrl}&config=${figgyUrl}/uv/uv_config.json`;
    iframeElement.src = src;

    return iframeElement;
  }

  constructViewerElement() {
    const viewerElement = document.createElement('div');
    viewerElement.setAttribute(
      'class',
      'intrinsic-container intrinsic-container-16x9'
    );
    viewerElement.id = this.buildViewerId();

    const iFrameElement = this.constructIFrame();
    viewerElement.appendChild(iFrameElement);

    return viewerElement;
  }

  async render() {
    const viewerElement = this.constructViewerElement();
    if (!viewerElement) {
      return null;
    }

    this.element.appendChild(viewerElement);
  }
}
class FiggyViewerSet {
  constructor(element, query, variables) {
    this.element = element;
    this.query = query;
    this.variables = variables;
  }

  async fetchResources() {
    const data = await this.query.call(this, this.variables);
    if (!data) {
      return null;
    }
    const resources = data.resourcesByOrangelightId;
    return resources;
  }

  getMemberIds(resources) {
    const ids = resources.map((resource) => {
      return resource.memberIds;
    });
    return ids.flat();
  }

  getManifestUrls(resources) {
    if (!resources) {
      return [];
    }

    // If there is a resource whose ID is included as a member_id of another resource,
    // filter it out
    const filterDuplicatedResources = resources.filter((resource) => {
      if (!resource['memberIds']) return true;
      const member_ids = this.getMemberIds(resources);
      const resource_is_unique = member_ids.map(() => {
        if (member_ids.includes(resource.id)) return false;
      });

      return !resource_is_unique.includes(false);
    });

    if (resources.length > 0 && filterDuplicatedResources.length < 1)
      return resources.map((resource) => {
        return resource.manifestUrl;
      });

    return filterDuplicatedResources.map((resource) => {
      return resource.manifestUrl;
    });
  }

  isUnauthorizedSeniorThesis(resource) {
    if (resource.notice !== undefined) {
      if (resource.notice) {
        const isSeniorThesis = resource.notice.heading.search('Senior Thesis');
        return resource.embed.status == 'unauthorized' && isSeniorThesis;
      }
    }
    return false;
  }

  // function for adding thesis request link
  addThesisRequestLinks(resources) {
    let iteration = 0;
    const link =
      'https://library.princeton.edu/special-collections/senior-thesis-order-form';
    const new_tab = '_blank';
    resources.forEach((resource) => {
      if (this.isUnauthorizedSeniorThesis(resource)) {
        const content = (link, new_tab) => {
          return `<a href="${link}" target="${new_tab}">Request a copy of ${resource.label}<i class="fa fa-external-link new-tab-icon-padding" aria-label="opens in new tab" role="img"></i></a><p>Princeton community has access to this thesis on campus or VPN.</p>`;
        };
        insert_online_link(link, `thesis_request_link_${iteration}`, content);
        iteration++;
      }
    });
  }

  async render() {
    const resources = await this.fetchResources();
    this.addThesisRequestLinks(resources);
    const filteredResources = resources.filter((resource) => {
      return !this.isUnauthorizedSeniorThesis(resource);
    });
    const manifestUrls = await this.getManifestUrls(filteredResources);
    manifestUrls.forEach((manifestUrl, idx) => {
      const viewer = new FiggyViewer(idx, this.element, manifestUrl);
      viewer.render();
    });
  }
}

// Queries for resources using multiple bib. IDs
class FiggyThumbnailSet {
  constructor(elements, query) {
    this.elements = Array.from(elements);
    this.query = query;
  }

  async fetchResources() {
    this.bibIds = this.elements.map((element) => element.dataset.bibId);

    const variables = { bibIds: this.bibIds };
    this.thumbnails = {};
    const data = await this.query.call(this, variables.bibIds);
    if (!data) {
      return null;
    }

    const resources = data.resourcesByOrangelightIds;
    this.resources = resources;

    // Cache the thumbnail URLs
    for (const resource of this.resources) {
      const orangelightId = resource.orangelightId;
      this.thumbnails[orangelightId] = resource.thumbnail;
    }
    return this.resources;
  }

  constructThumbnailElement(bibId) {
    const thumbnail = this.thumbnails[bibId];

    if (!thumbnail) {
      return Option.None();
    }

    const image = document.createElement('img');
    image.setAttribute('alt', '');
    image.setAttribute(
      'src',
      `${thumbnail.iiifServiceUrl}/square/225,/0/default.jpg`
    );
    return Option.Some(image);
  }

  async render() {
    await this.fetchResources();
    this.elements.map((element) => {
      const bibId = element.dataset.bibId;
      this.constructThumbnailElement(bibId).map((thumbnailElement) => {
        element.innerHTML = '';
        if (isRecordPagePath()) {
          wrapWithViewerLink(element);
        }
        element.appendChild(thumbnailElement);
      });
    });
  }
}

class FiggyManifestManager {
  static buildThumbnailSet(elements) {
    return new FiggyThumbnailSet(elements, loadResourcesByOrangelightIds);
  }

  // Build multiple viewers
  static buildViewers(element) {
    const bibId = element.dataset.bibId;
    return new FiggyViewerSet(
      element,
      loadResourcesByOrangelightId,
      bibId.toString()
    );
  }
}

export {
  FiggyManifestManager,
  FiggyViewer,
  FiggyViewerSet,
  wrapWithViewerLink,
  isRecordPagePath,
};

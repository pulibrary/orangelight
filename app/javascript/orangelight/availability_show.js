/*
  AvailabilitySearchResults is a subclass of AvailabilityBase
  search results status display rules:
  on-site access -> On-site access
  unavailable -> Unavailable
  'RES_SHARE$IN_RS_REQ' -> Unavailable
  available -> Available
  some available -> Some Available
  Everything that has a bibdata status Unavailable and is in
    marquand$* location -> Ask Staff
*/

import AvailabilityBase from './availability_base.js';

export default class AvailabilityShow extends AvailabilityBase {
  constructor() {
    super();

    this.process_single = this.process_single.bind(this);
    this.update_single = this.update_single.bind(this);
    this.update_availability_undetermined =
      this.update_availability_undetermined.bind(this);
    this.process_scsb_single = this.process_scsb_single.bind(this);
    this.availability_url_show = this.availability_url_show.bind(this);
  }

  /* example with three host ids: https://bibdata.princeton.edu/bibliographic/availability.json?deep=true&bib_ids=9923427953506421,99125038613506421,99125026373506421,99124945733506421 */
  // the record id is 9923427953506421
  availability_url_show() {
    return `${this.bibdata_base_url}/bibliographic/availability.json?deep=true&bib_ids=${this.#almaBibliographicIds().join(',')}`;
  }

  request_availability(allowRetry) {
    this.request_show_page_availability(allowRetry);
  }

  request_show_page_availability(allowRetry) {
    if (this.#scsbBibliographicIds().length > 0) {
      this.request_scsb_single_availability();
    }
    if (this.#almaBibliographicIds().length > 0) {
      this.request_show_availability(allowRetry);
    }
  }

  // process_single() is used in the Show page and typically `holding_records` only has the
  // information for a single bib since we are on the Show page. But occasionally the record
  // that we are showing is bound with another (host) record and in those instances
  // `holding_records` has data for two or more bibs: `this.id`, `this.host_ids`.
  process_single(holding_records) {
    // Availability response in bibdata should be refactored not to include the host holdings under the mms_id of the record page.
    // problematic availability response behavior for constituent record page with host records.
    // It treats host records as holdings of the constituent record. see: https://github.com/pulibrary/bibdata/issues/1739
    this.#allBibliographicIds().forEach((id) =>
      this.update_single(holding_records, id)
    );
  }

  update_single(holding_records, id) {
    return (() => {
      const result = [];
      for (const holding_id in holding_records[id]) {
        const availability_info = holding_records[id][holding_id];
        const { label } = holding_records[id][holding_id];
        const availability_element = this.#getAvailabilityElementForHolding(
          id,
          holding_id
        );
        if (holding_id !== 'RES_SHARE$IN_RS_REQ') {
          this.#updateHoldingLocation(
            label,
            availability_element,
            holding_records[id]
          );
        }
        this.apply_availability_label(availability_element, availability_info);
      }
      return result;
    })();
  }

  process_scsb_single(item_records) {
    let availability_info, barcode;
    const status_message = this.#determineMultiItemStatusMessage(item_records);
    return (() => {
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        const itemStatus = availability_info['itemAvailabilityStatus'];
        const availability_element = this.#getScsbAvailabilityElement(barcode);
        const aeon_element = this.#getScsbAeonElement(barcode);
        const aeon = aeon_element?.getAttribute('data-aeon');
        if (aeon === 'true') {
          if (availability_element) {
            availability_element.classList.add('lux-text-style');
          }
          this.status_display.setOnSiteAccessStatus(availability_element);
        } else if (status_message == 'Some Available') {
          this.status_display.setSomeAvailableStatus(availability_element);
        } else if (itemStatus == 'Unavailable') {
          this.status_display.setUnavailableStatus(availability_element);
        } else if (itemStatus == 'Available') {
          this.status_display.setAvailableStatus(availability_element);
        }
      }
    })();
  }

  request_scsb_single_availability() {
    this.#scsbBibliographicIds().forEach((scsbId) => {
      const url = `${this.availability_url}?scsb_id=${scsbId}`;
      fetch(url)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          this.process_scsb_single(data);
        })
        .catch((error) => {
          console.error(
            `Failed to retrieve availability data for the SCSB record ${this.#solrDocumentId()}: ${error}`
          );
        });
    });
  }

  request_show_availability(allowRetry) {
    fetch(this.availability_url_show())
      .then((response) => {
        if (response.status === 429) {
          if (allowRetry) {
            console.log(
              `Retrying availability for record ${this.#solrDocumentId()}`
            );
            window.setTimeout(() => {
              this.update_availability_retrying();
              this.request_availability(false);
            }, 1500);
            return;
          } else {
            console.error(
              `Failed to retrieve availability data for the bib (retry). Record ${this.#solrDocumentId()}: HTTP status 429`
            );
            this.update_availability_undetermined();
            return;
          }
        }
        if (!response.ok) {
          throw new Error(`HTTP status: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        if (data) {
          this.process_single(data);
        }
      })
      .catch((error) => {
        console.error(
          `Failed to retrieve availability data for the bib. record ${this.#solrDocumentId()}: ${error.message}`
        );
      });
  }

  handleOnSiteAccessStatus(availability_element) {
    this.status_display.setOnSiteAccessStatus(availability_element);
    return availability_element;
  }

  handle_availability_status(location, availability_element) {
    if (location.startsWith('marquand$')) {
      this.status_display.setAskStaffStatus(availability_element);
    } else {
      this.status_display.setUnavailableStatus(availability_element);
    }
  }

  update_availability_retrying() {
    const availability_span_display = document.querySelectorAll(
      `*[data-availability-record='true'] span.availability-icon`
    );
    availability_span_display.forEach((element) =>
      element.classList.add('lux-text-style')
    );
    this.status_display.setLoadingStatus(availability_span_display);
  }

  update_availability_undetermined() {
    const show_availability_display = document.querySelectorAll(
      `*[data-availability-record='true'] span.availability-icon`
    );
    this.status_display.setUndeterminedStatus(show_availability_display);
  }

  /**
   * The solr document ID
   */
  #solrDocumentId() {
    if (this.solrDocumentId === undefined) {
      this.solrDocumentId = window.location.pathname.split('/').pop();
    }
    return this.solrDocumentId;
  }

  /**
   * All bibliographic IDs on the DOM page
   *
   * @returns {string[]}
   */
  #allBibliographicIds() {
    return Array.from(this.#bibIdsFromDom().union(this.#hostIds()));
  }

  #almaBibliographicIds() {
    return this.#allBibliographicIds().filter(
      (id) => !this.#isScsb(id) && id.length < 25
    );
  }

  #scsbBibliographicIds() {
    return this.#allBibliographicIds()
      .filter((id) => this.#isScsb(id))
      .map((id) => id.replace(/^SCSB-/, ''));
  }

  #isScsb(id) {
    return id.match(/^SCSB-\d+/);
  }

  /**
   * Bibliographic ids found from the holdings section of the DOM
   *
   * @returns {Set<string>}
   */
  #bibIdsFromDom() {
    if (!this.bibIdsFromDom) {
      this.bibIdsFromDom = Array.from(
        document.querySelectorAll('[data-record-id]')
      ).reduce((acc, element) => {
        if (element?.dataset?.recordId) {
          acc.add(element.dataset.recordId);
        }
        return acc;
      }, new Set());
    }
    return this.bibIdsFromDom;
  }

  /**
   * Returns an array of 0, 1, or many host record ids based on the DOM content.
   * In the case of 0, the main-content tag has an empty data-host-id attribute.
   * Otherwise, that attribute will be an array with 1 or many elements
   *
   * @returns string[] of host record IDs found in the DOM
   */
  #hostIds() {
    const hostIdsFromDom = () => {
      const raw = document.getElementById('main-content')?.dataset?.hostId;
      if (!raw) {
        return new Set();
      }

      return new Set(JSON.parse(raw));
    };
    if (this.hostIds === undefined) {
      this.hostIds = hostIdsFromDom();
    }
    return this.hostIds;
  }

  #getAvailabilityElementForHolding(id, holding_id) {
    if (holding_id === 'RES_SHARE$IN_RS_REQ') {
      return this.#getResShareAvailabilityElement(id);
    }
    return this.#getStandardAvailabilityElement(id, holding_id);
  }

  #getResShareAvailabilityElement(id) {
    return document.querySelector(
      `*[data-availability-record='true'][data-record-id='${id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] .availability-icon`
    );
  }

  #getStandardAvailabilityElement(id, holding_id) {
    return document.querySelector(
      `*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}'] .availability-icon`
    );
  }

  #determineMultiItemStatusMessage(item_records) {
    if (Object.keys(item_records).length <= 1) {
      return undefined;
    }

    let hasAvailable = false;
    let hasUnavailable = false;

    for (const barcode in item_records) {
      const availability_info = item_records[barcode];

      if (availability_info['itemAvailabilityStatus'] === 'Available') {
        hasAvailable = true;
      } else {
        hasUnavailable = true;
      }
    }

    // Only return "Some Available" if we have both available and unavailable items
    if (hasAvailable && hasUnavailable) {
      return 'Some Available';
    }

    return undefined;
  }

  #getScsbAvailabilityElement(barcode) {
    return document.querySelector(
      `*[data-availability-record='true'][data-scsb-barcode='${barcode}'] .availability-icon`
    );
  }

  #getScsbAeonElement(barcode) {
    return document.querySelector(
      `*[data-availability-record='true'][data-record-id='${this.#solrDocumentId()}'][data-scsb-barcode='${barcode}']`
    );
  }

  #updateHoldingLocation(label, availability_element, all_holdings) {
    if (label && availability_element) {
      const detailsElement = availability_element.closest('details');
      if (detailsElement) {
        const holdingsInGroup = detailsElement.querySelectorAll(
          '[data-availability-record="true"]'
        );

        // Update the group label if:
        // 1. There's only one holding in the details group, OR
        // 2. All holdings in this group have the same label from bibdata availability response
        const shouldUpdate =
          holdingsInGroup.length === 1 ||
          this.#allHoldingsHaveSameLabel(holdingsInGroup, all_holdings);

        if (shouldUpdate) {
          const holding_location = detailsElement.querySelector(
            'summary div.side-by-side span.text'
          );
          if (holding_location) {
            holding_location.textContent = label;
          }
        }
      }
    }
  }

  #allHoldingsHaveSameLabel(holdingsInGroup, all_holdings) {
    if (holdingsInGroup.length <= 1) {
      return false;
    }

    const holdingIdsInGroup = Array.from(holdingsInGroup).map((el) =>
      el.getAttribute('data-holding-id')
    );

    const labelsInGroup = holdingIdsInGroup
      .map((holdingId) => all_holdings[holdingId]?.label)
      .filter((holding_label) => holding_label !== undefined);

    return (
      labelsInGroup.length > 0 &&
      labelsInGroup.every((label) => label === labelsInGroup[0])
    );
  }
}

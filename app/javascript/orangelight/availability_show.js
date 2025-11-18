import AvailabilityBase from './availability_base.js';

export default class AvailabilityShow extends AvailabilityBase {
  constructor() {
    super();
    this.id = '';
    this.host_id = '';

    this.process_single = this.process_single.bind(this);
    this.update_single = this.update_single.bind(this);
    this.update_availability_undetermined =
      this.update_availability_undetermined.bind(this);
    this.process_scsb_single = this.process_scsb_single.bind(this);
    this.availability_url_show = this.availability_url_show.bind(this);
  }

  request_availability(allowRetry) {
    if (
      document.querySelectorAll("*[data-availability-record='true']").length > 0
    ) {
      this.request_show_page_availability(allowRetry);
    }
  }

  request_show_page_availability(allowRetry) {
    this.id = window.location.pathname.split('/').pop();
    const mainContent = document.getElementById('main-content');
    const hostIdAttr = mainContent
      ? mainContent.getAttribute('data-host-id') || ''
      : '';
    if (hostIdAttr && hostIdAttr.startsWith('[') && hostIdAttr.endsWith(']')) {
      const parsed = JSON.parse(hostIdAttr);
      this.host_id = Array.isArray(parsed) ? parsed.join(',') : hostIdAttr;
    } else {
      this.host_id = hostIdAttr;
    }
    if (this.id.match(/^SCSB-\d+/)) {
      this.request_scsb_single_availability();
    } else {
      this.request_show_availability(allowRetry);
    }
  }

  request_scsb_single_availability() {
    const url = `${this.availability_url}?scsb_id=${this.id.replace(/^SCSB-/, '')}`;
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
          `Failed to retrieve availability data for the SCSB record ${this.id}: ${error}`
        );
      });
  }

  request_show_availability(allowRetry) {
    const url = this.availability_url_show();
    fetch(url)
      .then((response) => {
        if (response.status === 429) {
          if (allowRetry) {
            console.log(`Retrying availability for record ${this.id}`);
            window.setTimeout(() => {
              this.update_availability_retrying();
              this.request_availability(false);
            }, 1500);
            return;
          } else {
            console.error(
              `Failed to retrieve availability data for the bib (retry). Record ${this.id}: HTTP status 429`
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
          `Failed to retrieve availability data for the bib. record ${this.id}: ${error.message}`
        );
      });
  }

  /* example with three host ids: https://bibdata.princeton.edu/bibliographic/availability.json?deep=true&bib_ids=9923427953506421,99125038613506421,99125026373506421,99124945733506421 */
  // the record id is 9923427953506421
  availability_url_show() {
    let url = `${this.bibdata_base_url}/bibliographic/availability.json?deep=true&bib_ids=${this.id}`;
    if (this.host_id.length > 0) {
      const hostIds = Array.isArray(this.host_id)
        ? this.host_id.join(',')
        : this.host_id;
      url += `,${hostIds}`;
    }
    return url;
  }

  // process_single() is used in the Show page and typically `holding_records` only has the
  // information for a single bib since we are on the Show page. But occasionally the record
  // that we are showing is bound with another (host) record and in those instances
  // `holding_records` has data for two or more bibs: `this.id`, `this.host_id`.
  process_single(holding_records) {
    this.update_single(holding_records, this.id);
    // Availability response in bibdata should be refactored not to include the host holdings under the mms_id of the record page.
    // problematic availability response behavior for constituent record page with host records.
    // It treats host records as holdings of the constituent record. see: https://github.com/pulibrary/bibdata/issues/1739
    if (this.host_id.length > 0) {
      const hostIds = Array.isArray(this.host_id)
        ? this.host_id
        : [this.host_id];
      hostIds.forEach((mms_id) => {
        this.update_single(holding_records, mms_id);
      });
    }
  }

  update_single(holding_records, id) {
    return (() => {
      const result = [];
      for (const holding_id in holding_records[id]) {
        const availability_info = holding_records[id][holding_id];
        const { label } = holding_records[id][holding_id];
        // case :constituent with host ids.
        // data-record-id has a different this.id when there are host ids.
        let availability_element;

        // If we are not getting holding info select the availability element by record id only.
        if (holding_id == 'RES_SHARE$IN_RS_REQ') {
          availability_element = document.querySelector(
            `*[data-availability-record='true'][data-record-id='${id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] .availability-icon`
          );
        } else {
          availability_element = document.querySelector(
            `*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}'] .availability-icon`
          );
        }
        if (label) {
          const holding_location = document.querySelector(
            `*[data-location='true'][data-holding-id='${holding_id}']`
          );
          if (holding_location) {
            holding_location.textContent = label;
          }
        }
        this.apply_availability_label(availability_element, availability_info);
        result.push(this.update_request_button(holding_id));
      }
      return result;
    })();
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

  process_scsb_single(item_records) {
    let availability_info, barcode, multi_items, status_message;
    if (Object.keys(item_records).length > 1) {
      multi_items = true;
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        if (availability_info['itemAvailabilityStatus'] !== 'Available') {
          status_message = 'Unavailable';
        }
      }
    }
    return (() => {
      const result = [];
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        const availability_element = document.querySelector(
          `*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}'] .availability-icon`
        );
        const aeon_element = document.querySelector(
          `*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}']`
        );
        const aeon = aeon_element?.getAttribute('data-aeon');
        if (aeon === 'true') {
          if (availability_element) {
            availability_element.classList.add('lux-text-style');
          }
          this.status_display.setOnSiteAccessStatus(availability_element);
          result.push(availability_element);
        } else if (multi_items) {
          if (status_message) {
            if (availability_element) {
              availability_element.classList.add('gray', 'strong');
              availability_element.textContent = status_message;
            }
            result.push(availability_element);
          } else {
            this.status_display.setAvailableStatus(availability_element);
            result.push(availability_element);
          }
        } else {
          if (availability_info['itemAvailabilityStatus'] === 'Available') {
            this.status_display.setAvailableStatus(availability_element);
            result.push(availability_element);
          } else {
            this.status_display.setUnavailableStatus(availability_element);
            result.push(availability_element);
          }
        }
      }
      return result;
    })();
  }

  update_request_button(holding_id) {
    const location_services_element = document.querySelector(
      `.location-services[data-holding-id='${holding_id}'] a`
    );
  }

  handleOnSiteAccessStatus(availability_element) {
    // For show page, on-site access shows the specific status
    this.status_display.setOnSiteAccessStatus(availability_element);
    return availability_element;
  }

  handle_availability_status(
    location,
    availability_element,
    specialStatusLocations
  ) {
    if (specialStatusLocations.includes(location)) {
      this.checkSpecialLocation(location, availability_element);
    } else {
      // For show page, unavailable items show as Unavailable
      this.status_display.setUnavailableStatus(availability_element);
    }
  }

  checkSpecialLocation(location, availability_element) {
    if (location.startsWith('marquand$')) {
      this.status_display.setAskStaffStatus(availability_element);
    } else {
      this.status_display.setUnavailableStatus(availability_element);
    }
    return availability_element;
  }

  setUnavailableStatus(availability_element) {
    // For show page, unavailable items show as Unavailable
    this.status_display.setUnavailableStatus(availability_element);
  }

  setMarquandStatus(availability_element) {
    this.status_display.setAskStaffStatus(availability_element);
  }
}

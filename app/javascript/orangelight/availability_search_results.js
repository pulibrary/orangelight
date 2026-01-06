/*
  AvailabilitySearchResults is a subclass of AvailabilityBase
  search results status display rules:
  on-site access -> Available
  unavailable -> Request
  available -> Available
  some available -> Available
  specialStatusLocations -> Request 
      'marquand$stacks',
      'marquand$pj',
      'marquand$ref',
      'marquand$ph',
      'marquand$fesrf',
*/
import AvailabilityBase from './availability_base.js';

export default class AvailabilitySearchResults extends AvailabilityBase {
  constructor() {
    super();
    this.process_results_list = this.process_results_list.bind(this);
    this.process_barcodes = this.process_barcodes.bind(this);
    this.update_availability_undetermined =
      this.update_availability_undetermined.bind(this);
    this.update_availability_retrying =
      this.update_availability_retrying.bind(this);
  }

  request_availability() {
    if (document.querySelectorAll('.documents-list').length > 0) {
      this.request_search_results_availability();
    }
  }

  process_barcodes(barcodes) {
    return (() => {
      const result = [];
      for (const barcode_id in barcodes) {
        const item_data = barcodes[barcode_id];
        result.push(this.#apply_scsb_record(barcode_id, item_data));
      }
      return result;
    })();
  }

  process_results_list(records) {
    console.log(`Batch finished at ${new Date().toISOString()}`);
    const result = [];
    for (const record_id in records) {
      const holding_records = records[record_id];
      result.push(this.process_result(record_id, holding_records));
    }
    return result;
  }

  process_result(record_id, holding_records) {
    for (const holding_id in holding_records) {
      const availability_info = holding_records[holding_id];
      const { label, location, temp_location } = availability_info;

      if (this.#isTempLocation(holding_id, temp_location)) {
        this.#updateTemporaryLocationAvailability(record_id, holding_id);
      } else {
        this.#updateLibraryName(record_id, holding_id, label, location);
        this.#updateAvailabilityLabel(record_id, holding_id, availability_info);
      }
    }
    // Bibdata does not know about bound-with records and therefore we don't get availability
    // information for holdings coming from the host record.
    // For those holdings we display Available in the search results page.
    const boundWithDisplays = document.querySelectorAll(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-bound-with='true'] span.lux-text-style`
    );
    boundWithDisplays.forEach((display) => {
      this.status_display.setAvailableStatus(display);
    });
    return true;
  }

  #updateTemporaryLocationAvailability(record_id, holding_id) {
    // We assume that items in temp locations are always available
    // except RES_SHARE$IN_RS_REQ which is unavailable.
    const availability_display_element = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] span.lux-text-style`
    );
    const availability_display_element_res_share = document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] span.lux-text-style`
    );
    if (holding_id !== 'RES_SHARE$IN_RS_REQ') {
      return this.status_display.setAvailableStatus(
        availability_display_element
      );
    } else {
      return this.status_display.setRequestStatus(
        availability_display_element_res_share
      );
    }
  }

  request_search_results_availability() {
    const bib_ids = this.#record_ids();
    if (bib_ids.length < 1) {
      return;
    }

    const batch_size = 10;
    const batches = this.#ids_to_batches(bib_ids, batch_size);
    console.log(
      `Requested at ${new Date().toISOString()}, batch size: ${batch_size}, batches: ${batches.length}, ids: ${bib_ids.length}`
    );

    for (let i = 0; i < batches.length; i++) {
      const batch_ids = batches[i].join(',');
      const batch_url =
        this.bibdata_base_url +
        '/bibliographic/availability.json?bib_ids=' +
        batch_ids;
      console.log('batch: ' + i + ', url: ' + batch_url);
      fetch(batch_url)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          this.process_results_list(data);
        })
        .catch((error) => {
          console.error(
            `Failed to retrieve availability data for batch. ${error}`
          );
        });
    }
  }

  scsb_search_availability() {
    const documents_list = document.querySelectorAll('.documents-list');
    if (documents_list.length > 0) {
      const barcodes = this.#scsbBarcodes();
      if (barcodes.length < 1) {
        return;
      }
      const params = new URLSearchParams();
      barcodes.forEach((barcode) => params.append('barcodes[]', barcode));
      const url = `${this.availability_url}?${params}`;
      return fetch(url)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP status: ${response.status}`);
          }
          return response.json();
        })
        .then((data) => {
          return this.process_barcodes(data);
        })
        .catch((error) => {
          console.error(
            `Failed to retrieve availability data for the SCSB barcodes ${barcodes.join(
              ', '
            )}: ${error.message}`
          );
        });
    }
  }

  handle_availability_status(
    location,
    availability_element,
    specialStatusLocations
  ) {
    this.status_display.setRequestStatus(availability_element);
  }

  handleOnSiteAccessStatus(availability_element) {
    // For search results, on-site access shows as Available
    this.status_display.setAvailableStatus(availability_element);
    return availability_element;
  }

  update_availability_undetermined() {
    const search_availability_display = document.querySelectorAll(
      `*[data-availability-record='true'] span.lux-text-style`
    );
    this.status_display.setUndeterminedStatus(search_availability_display);
  }

  update_availability_retrying() {
    const availability_display = document.querySelectorAll(
      `*[data-availability-record='true'] span.lux-text-style`
    );
    this.status_display.setLoadingStatus(availability_display);
  }

  _getLibraryName(label, location) {
    let library_name;
    const library_in_use = {
      arch$pw: 'Archictecture (Remote Storage)',
      eastasian$pl: 'East Asian (Remote Storage)',
      eastasian$ql: 'East Asian (Remote Storage)',
      engineer$pt: 'Engineering (Remote Storage)',
      firestone$pb: 'Firestone (Remote Storage)',
      firestone$pf: 'Firestone (Remote Storage)',
      lewis$pn: 'Lewis (Remote Storage)',
      lewis$ps: 'Lewis (Remote Storage)',
      mendel$pk: 'Mendel (Remote Storage)',
      mendel$qk: 'Mendel (Remote Storage)',
      stokes$pm: 'Stokes (Remote Storage)',
      marquand$pj: 'Marquand (Remote Storage)',
      marquand$pjm: 'Marquand (Remote Storage)',
      marquand$pv: 'Marquand (Remote Storage)',
      marquand$pz: 'Marquand (Remote Storage)',
    };
    if (location in library_in_use) {
      library_name = library_in_use[location];
    } else {
      library_name = label.replace(/-(.*)/, '').trim();
    }
    return library_name;
  }
  #apply_scsb_record(barcode, item_data) {
    const availability_element = document.querySelector(
      `*[data-scsb-availability='true'][data-scsb-barcode='${barcode}']`
    );
    if (availability_element) {
      if (item_data['itemAvailabilityStatus'] === 'Available') {
        this.status_display.setAvailableStatus(availability_element);
      } else {
        this.status_display.setRequestStatus(availability_element);
      }
    }
    return true;
  }

  #ids_to_batches(ids, batch_size) {
    const batches = [];
    const batch_count =
      Math.floor(ids.length / batch_size) + (ids.length % batch_size);
    let i, begin, end, batch;
    for (i = 0; i < batch_count; i++) {
      begin = i * batch_size;
      end = begin + batch_size;
      batch = ids.slice(begin, end);
      if (batch.length == 0) {
        break;
      }
      batches.push(batch);
    }
    return batches;
  }

  #record_ids() {
    const ids = Array.from(
      document.querySelectorAll(
        "*[data-availability-record='true'][data-record-id]"
      )
    ).map(function (node) {
      return node.getAttribute('data-record-id');
    });

    return [...new Set(ids)];
  }

  #scsbBarcodes() {
    return Array.from(
      document.querySelectorAll(
        "*[data-scsb-availability='true'][data-scsb-barcode]"
      )
    ).map(function (node) {
      return node.getAttribute('data-scsb-barcode');
    });
  }

  #isTempLocation(holding_id, temp_location) {
    if (temp_location !== undefined) {
      return temp_location;
    }
    // Fallback to pattern matching for backwards compatibility
    if (holding_id.match(/[a-zA-Z]\$[a-zA-Z]/)) {
      return true;
    }
    return false;
  }

  #updateLibraryName(record_id, holding_id, label, location) {
    if (label && location) {
      const element = this.#getLocationElement(record_id, holding_id);
      if (element) {
        element.textContent = this._getLibraryName(label, location);
      }
    }
  }

  #updateAvailabilityLabel(record_id, holding_id, availability_info) {
    const element = this.#getAvailabilityElement(record_id, holding_id);
    if (element) {
      this.apply_availability_label(element, availability_info);
    }
  }

  #getLocationElement(record_id, holding_id) {
    return document.querySelector(
      `*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location .search-result-library-name`
    );
  }

  #getAvailabilityElement(record_id, holding_id) {
    // The following query selector will not return for temporary RES_SHARE$IN_RS_REQ.
    // This is the desired behavior for this temporary location.
    return document.querySelector(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .lux-text-style`
    );
  }
}

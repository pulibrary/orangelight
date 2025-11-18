import AvailabilityBase from './availability_base.js';

export default class AvailabilitySearchResults extends AvailabilityBase {
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

  request_search_results_availability() {
    const bib_ids = this.#record_ids();
    if (bib_ids.length < 1) {
      return;
    }

    const batch_size = 10;
    const batches = this.ids_to_batches(bib_ids, batch_size);
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
      const barcodes = this.scsb_barcodes();
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

  process_barcodes(barcodes) {
    return (() => {
      const result = [];
      for (const barcode_id in barcodes) {
        const item_data = barcodes[barcode_id];
        result.push(this.apply_scsb_record(barcode_id, item_data));
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
      if (holding_id === 'RES_SHARE$IN_RS_REQ') {
        // This holding location should always show as Request in the search results.
        const availability_display = document.querySelector(
          `*[data-availability-record='true'][data-record-id='${record_id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] span.lux-text-style`
        );
        this.status_display.setRequestStatus(availability_display);
        return true;
      }
      if (holding_id.match(/[a-zA-Z]\$[a-zA-Z]/)) {
        // We assume that items in temp locations are available.
        const availability_display = document.querySelector(
          `*[data-availability-record='true'][data-record-id='${record_id}'] span.lux-text-style`
        );
        this.status_display.setAvailableStatus(availability_display);
        return true;
      }

      // In Alma the label from the endpoint includes both the library name and the location.
      const availability_info = holding_records[holding_id];
      const { label, location } = availability_info;
      if (label && location) {
        const availability_location = document.querySelector(
          `*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location .search-result-library-name`
        );
        if (availability_location) {
          availability_location.textContent = this._getLibraryName(
            label,
            location
          );
        }
      }
      const availability_element = document.querySelector(
        `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .lux-text-style`
      );
      if (availability_element) {
        this.apply_availability_label(availability_element, availability_info);
      }
    }

    // Bib data does not know about bound-with records and therefore we don't get availability
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

  ids_to_batches(ids, batch_size) {
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

  scsb_barcodes() {
    return Array.from(
      document.querySelectorAll(
        "*[data-scsb-availability='true'][data-scsb-barcode]"
      )
    ).map(function (node) {
      return node.getAttribute('data-scsb-barcode');
    });
  }

  apply_scsb_record(barcode, item_data) {
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

  handle_availability_status(
    location,
    availability_element,
    specialStatusLocations
  ) {
    if (specialStatusLocations.includes(location)) {
      this.checkSpecialLocation(location, availability_element);
    } else {
      // For search results, unavailable items show as Request
      this.status_display.setRequestStatus(availability_element);
    }
  }

  checkSpecialLocation(location, availability_element) {
    if (location.startsWith('marquand$')) {
      this.status_display.setRequestStatus(availability_element);
    } else {
      this.status_display.setRequestStatus(availability_element);
    }
    return availability_element;
  }

  handleOnSiteAccessStatus(availability_element) {
    // For search results, on-site access shows as Available
    this.status_display.setAvailableStatus(availability_element);
    return availability_element;
  }

  setUnavailableStatus(availability_element) {
    this.status_display.setRequestStatus(availability_element);
  }

  setMarquandStatus(availability_element) {
    this.status_display.setRequestStatus(availability_element);
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
}

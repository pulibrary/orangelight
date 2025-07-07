import { insert_online_link } from './insert_online_link.es6';

export default class AvailabilityUpdater {
  constructor() {
    this.bibdata_base_url = $('body').data('bibdata-base-url');
    this.availability_url = `${this.bibdata_base_url}/availability`;
    this.id = '';
    this.host_id = '';

    this.process_results_list = this.process_results_list.bind(this);
    this.process_barcodes = this.process_barcodes.bind(this);
    this.process_single = this.process_single.bind(this);
    this.update_single = this.update_single.bind(this);
    this.update_availability_undetermined =
      this.update_availability_undetermined.bind(this);
    this.process_scsb_single = this.process_scsb_single.bind(this);
    this.availability_url_show = this.availability_url_show.bind(this);
  }

  request_availability(allowRetry) {
    let url;
    // a search results page or a call number browse page
    if ($('.documents-list').length > 0) {
      const bib_ids = this.record_ids();
      if (bib_ids.length < 1) {
        return;
      }

      const batch_size = 10;
      const batches = this.ids_to_batches(bib_ids, batch_size);
      console.log(
        `Requested at ${new Date().toISOString()}, batch size: ${batch_size}, batches: ${batches.length}, ids: ${bib_ids.length}`
      );

      for (let i = 0; i < batches.length; i++) {
        const batch_url = `${this.bibdata_base_url}/bibliographic/availability.json?bib_ids=${batches[i].join()}`;
        console.log(`batch: ${i}, url: ${batch_url}`);
        $.getJSON(batch_url, this.process_results_list).fail(
          (jqXHR, _textStatus, errorThrown) => {
            // Log that there were problems fetching a batch. Unfortunately we don't know exactly
            // which batch so we cannot include that information.
            console.error(
              `Failed to retrieve availability data for batch. HTTP status: ${jqXHR.status}: ${errorThrown}`
            );
          }
        );
      }

      // a show page
    } else if ($("*[data-availability-record='true']").length > 0) {
      this.id = window.location.pathname.split('/').pop();
      this.host_id = $('#main-content').data('host-id') || '';
      if (this.id.match(/^SCSB-\d+/)) {
        url = `${this.availability_url}?scsb_id=${this.id.replace(/^SCSB-/, '')}`;
        return $.getJSON(url, this.process_scsb_single).fail(
          (jqXHR, textStatus, errorThrown) => {
            return console.error(
              `Failed to retrieve availability data for the SCSB record ${this.id}: ${errorThrown}`
            );
          }
        );
      } else {
        return $.getJSON(
          this.availability_url_show(),
          this.process_single
        ).fail((jqXHR, textStatus, errorThrown) => {
          if (jqXHR.status == 429) {
            if (allowRetry) {
              console.log(`Retrying availability for record ${this.id}`);
              window.setTimeout(() => {
                this.update_availability_retrying();
                this.request_availability(false);
              }, 1500);
            } else {
              console.error(
                `Failed to retrieve availability data for the bib (retry). Record ${this.id}: ${errorThrown}`
              );
              this.update_availability_undetermined();
            }
            return;
          }
          return console.error(
            `Failed to retrieve availability data for the bib. record ${this.id}: ${errorThrown}`
          );
        });
      }
    }
  }
  /* example with three host ids: https://bibdata.princeton.edu/bibliographic/availability.json?deep=true&bib_ids=9923427953506421,99125038613506421,99125026373506421,99124945733506421 */
  // the record id is 9923427953506421
  availability_url_show() {
    let url = `${this.bibdata_base_url}/bibliographic/availability.json?deep=true&bib_ids=${this.id}`;
    if (this.host_id.length > 0) {
      url += `,${this.host_id}`;
    }
    return url;
  }

  scsb_search_availability() {
    if ($('.documents-list').length > 0) {
      const barcodes = this.scsb_barcodes();
      if (barcodes.length < 1) {
        return;
      }
      const params = $.param({ barcodes });
      const url = `${this.availability_url}?${params}`;
      return $.getJSON(url, this.process_barcodes).fail(
        (jqXHR, textStatus, errorThrown) => {
          return console.error(
            `Failed to retrieve availability data for the SCSB barcodes ${barcodes.join(', ')}: ${errorThrown}`
          );
        }
      );
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

  // search results
  process_result(record_id, holding_records) {
    for (const holding_id in holding_records) {
      if (holding_id === 'RES_SHARE$IN_RS_REQ') {
        // This holding location should always show as Request
        const badges = $(
          `*[data-availability-record='true'][data-record-id='${record_id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] span.availability-icon`
        );
        badges.addClass('bg-danger');
        badges.text('Request');
        return true;
      }
      if (holding_id.match(/[a-zA-Z]\$[a-zA-Z]/)) {
        // We assume that items in temp locations are available.
        const badges = $(
          `*[data-availability-record='true'][data-record-id='${record_id}'] span.availability-icon`
        );
        badges.text('Available');
        return true;
      }

      // In Alma the label from the endpoint includes both the library name and the location.
      const availability_info = holding_records[holding_id];
      const { label } = availability_info;
      if (label) {
        const location = $(
          `*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location`
        );
        location.text(label);
      }
      const availability_element = $(
        `*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .availability-icon`
      );
      this.apply_availability_label(availability_element, availability_info);
    }

    // Bib data does not know about bound-with records and therefore we don't get availability
    // information for holdings coming from the host record.
    // For those holdings we display Available in the search results page.
    const boundWithBadges = $(
      `*[data-availability-record='true'][data-record-id='${record_id}'][data-bound-with='true'] span.availability-icon`
    );
    boundWithBadges.text('Available');

    return true;
  }

  // process_single() is used in the Show page and typically `holding_records` only has the
  // information for a single bib since we are on the Show page. But occasionally the record
  // that we are showing is bound with another (host) record and in those instances
  // `holding_records` has data for two or more bibs: `this.id`, `this.host_id`.
  process_single(holding_records) {
    this.update_single(holding_records, this.id);
    // Availability response in bibdata should be refactored not to include the host holdings under the mms_id of the record page.
    // problematic availability response behaviour for constituent record page with host records.
    // It treats host records as holdings of the constituent record. see: https://github.com/pulibrary/bibdata/issues/1739
    if (this.host_id.length > 0) {
      this.host_id.forEach((mms_id) => {
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
          availability_element = $(
            `*[data-availability-record='true'][data-record-id='${id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] .availability-icon`
          );
        } else {
          availability_element = $(
            `*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}'] .availability-icon`
          );
        }
        if (label) {
          const holding_location = $(
            `*[data-location='true'][data-holding-id='${holding_id}']`
          );
          holding_location.text(label);
        }
        this.apply_availability_label(availability_element, availability_info);
        result.push(this.update_request_button(holding_id, availability_info));
      }
      return result;
    })();
  }

  // Sets the availability badge to indicate that we are retrying to fetch the information
  update_availability_retrying() {
    const avBadges = $(
      `*[data-availability-record='true'] span.availability-icon`
    );
    $(avBadges).text('Loading...');
    $(avBadges).addClass('badge bg-secondary');
  }

  // Sets the availability badge to indicate that we could not determine the availability
  update_availability_undetermined() {
    const avBadges = $(
      `*[data-availability-record='true'] span.availability-icon`
    );
    $(avBadges).text('Undetermined');
    $(avBadges).addClass('badge bg-secondary');
  }

  process_scsb_single(item_records) {
    let availability_info, barcode, multi_items, status_message;
    if (Object.keys(item_records).length > 1) {
      multi_items = true;
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        if (availability_info['itemAvailabilityStatus'] !== 'Available') {
          status_message = 'Request';
        }
      }
    }
    return (() => {
      const result = [];
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        const availability_element = $(
          `*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}'] .availability-icon`
        );
        const aeon = $(
          `*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}']`
        ).attr('data-aeon');
        availability_element.addClass('badge');
        if (aeon === 'true') {
          availability_element.addClass('bg-success');
          availability_element.text('Available');
          result.push(availability_element);
        } else if (multi_items) {
          if (status_message) {
            availability_element.addClass('bg-secondary');
            availability_element.text(status_message);
            result.push(availability_element);
          } else {
            availability_element.addClass('bg-success');
            availability_element.text('All Items Available');
            result.push(availability_element);
          }
        } else {
          if (availability_info['itemAvailabilityStatus'] === 'Available') {
            availability_element.addClass('bg-success');
            availability_element.text(
              availability_info['itemAvailabilityStatus']
            );
            result.push(availability_element);
          } else {
            availability_element.addClass('bg-danger');
            availability_element.text(
              availability_info['itemAvailabilityStatus']
            );
            result.push(availability_element);
          }
        }
      }
      return result;
    })();
  }

  record_ids() {
    return Array.from(
      document.querySelectorAll(
        "*[data-availability-record='true'][data-record-id]"
      )
    ).map(function (node) {
      return node.getAttribute('data-record-id');
    });
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

  update_request_button(holding_id, availability_info) {
    const location_services_element = $(
      `.location-services[data-holding-id='${holding_id}'] a`
    );
  }

  apply_scsb_record(barcode, item_data) {
    const availability_element = $(
      `*[data-scsb-availability='true'][data-scsb-barcode='${barcode}']`
    );
    if (item_data['itemAvailabilityStatus'] === 'Available') {
      availability_element.addClass('bg-success');
      availability_element.text(item_data['itemAvailabilityStatus']);
      availability_element;
    } else {
      availability_element.addClass('bg-danger');
      availability_element.text(item_data['itemAvailabilityStatus']);
      availability_element;
    }
    return true;
  }

  apply_availability_label(availability_element, availability_info) {
    availability_element.addClass('badge');
    const { status_label, location, id } = availability_info;
    const specialStatusLocations = [
      'marquand$stacks',
      'marquand$pj',
      'marquand$ref',
      'marquand$ph',
      'marquand$fesrf',
      'RES_SHARE$IN_RS_REQ',
    ];
    availability_element.text(status_label);
    if (status_label.toLowerCase() === 'request') {
      if (specialStatusLocations.includes(location)) {
        this.checkSpecialLocation(location, availability_element);
      } else {
        availability_element.addClass('bg-danger');
      }
    } else if (status_label.toLowerCase() === 'available') {
      availability_element.addClass('bg-success');
    } else {
      availability_element.addClass('bg-secondary');
    }
    return availability_element;
  }

  title_case(str) {
    return (
      str[0].toUpperCase() +
      str.slice(1, +(str.length - 1) + 1 || undefined).toLowerCase()
    );
  }

  // Set status for specific Marquand locations and location RES_SHARE$IN_RS_REQ
  checkSpecialLocation(location, availability_element) {
    if (location.startsWith('marquand$')) {
      availability_element.text('Request').addClass('bg-secondary');
    } else {
      availability_element.text('Request').addClass('bg-danger');
    }
    return availability_element;
  }

  /* Currently this logic is duplicated in Ruby code in application_helper.rb (ApplicationHelper::find_it_location) */
  find_it_location(location) {
    if (location.startsWith('plasma$') || location.startsWith('marquand$')) {
      return false;
    }
    return true;
  }
}

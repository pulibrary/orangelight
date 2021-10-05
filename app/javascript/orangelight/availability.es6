/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import { insert_online_link } from 'orangelight/insert_online_link'

export default class AvailabilityUpdater {

  constructor() {
    this.bibdata_base_url = $("body").data("bibdata-base-url");
    this.availability_url = `${this.bibdata_base_url}/availability`;
    this.id = '';
    this.host_id = '';

    this.available_non_requestable_labels = ['Available', 'Returned', 'Requestable',
      'On shelf', 'All items available', 'On-site access',
      'On-site - in-transit discharged', 'Reserved for digital lending'];

    this.process_results_list = this.process_results_list.bind(this);
    this.process_barcodes = this.process_barcodes.bind(this);
    this.process_single = this.process_single.bind(this);
    this.update_single = this.update_single.bind(this);
    this.update_availability_undetermined = this.update_availability_undetermined.bind(this);
    this.process_scsb_single = this.process_scsb_single.bind(this);
    this.availability_url_show = this.availability_url_show.bind(this);
  }

  request_availability(allowRetry) {
    let url;
    // a search results page or a call number browse page
    if ($(".documents-list").length > 0) {
      const bib_ids = this.record_ids();
      if (bib_ids.length < 1) { return; }
      url = `${this.bibdata_base_url}/bibliographic/availability.json?bib_ids=${bib_ids.join()}`;
      return $.getJSON(url, this.process_results_list)
        .fail((jqXHR, textStatus, errorThrown) => {
          if (jqXHR.status == 429) {
            if (allowRetry) {
              console.log(`Retrying availability for records ${bib_ids.join()}`);
              window.setTimeout(() => {
                this.update_availability_retrying();
                this.request_availability(false);
              }, 1500);
            } else {
              console.error(`Failed to retrieve availability data for bibs (retry). Records ${bib_ids.join()}: ${errorThrown}`);
              this.update_availability_undetermined();
            }
            return;
          }
          return console.error(`Failed to retrieve availability data for bibs. Records ${bib_ids.join(", ")}: ${errorThrown}`);
        });

    // a show page
    } else if ($("*[data-availability-record='true']").length > 0) {
      this.id = window.location.pathname.split('/')[2];
      this.host_id = $("#main-content").data("host-id") || "";
      if (this.id.match(/^SCSB-\d+/)) {
        url = `${this.availability_url}?scsb_id=${this.id.replace(/^SCSB-/, '')}`;
        return $.getJSON(url, this.process_scsb_single)
          .fail((jqXHR, textStatus, errorThrown) => {
            return console.error(`Failed to retrieve availability data for the SCSB record ${id}: ${errorThrown}`);
          });

      } else {
        return $.getJSON(this.availability_url_show(), this.process_single)
          .fail((jqXHR, textStatus, errorThrown) => {
            if (jqXHR.status == 429) {
              if (allowRetry) {
                console.log(`Retrying availability for record ${this.id}`);
                window.setTimeout(() => {
                  this.update_availability_retrying();
                  this.request_availability(false);
                }, 1500);
              } else {
                console.error(`Failed to retrieve availability data for the bib (retry). Record ${this.id}: ${errorThrown}`);
                this.update_availability_undetermined();
              }
              return;
            }
            return console.error(`Failed to retrieve availability data for the bib. record ${this.id}: ${errorThrown}`);
          });
      }
    }
  }

  availability_url_show() {
    let url = `${this.bibdata_base_url}/bibliographic/availability.json?deep=true&bib_ids=${this.id}`
    if (this.host_id !== "") {
      url += `,${this.host_id}`
    }
    return url
  }

  scsb_search_availability() {
    if ($(".documents-list").length > 0) {
      const barcodes = this.scsb_barcodes();
      if (barcodes.length < 1) { return; }
      const params = $.param({barcodes});
      const url = `${this.availability_url}?${params}`;
      return $.getJSON(url, this.process_barcodes)
        .fail((jqXHR, textStatus, errorThrown) => {
          return console.error(`Failed to retrieve availability data for the SCSB barcodes ${barcodes.join(", ")}: ${errorThrown}`);
        });
    }
  }

  process_barcodes(barcodes) {
    return (() => {
      const result = [];
      for (let barcode_id in barcodes) {
        const item_data = barcodes[barcode_id];
        result.push(this.apply_scsb_record(barcode_id, item_data));
      }
      return result;
    })();
  }

  process_results_list(records) {
    let result = [];
    for (let record_id in records) {
      const holding_records = records[record_id];
      result.push(this.process_result(record_id, holding_records));
    }
    return result;
  }

  // search results
  process_result(record_id, holding_records) {
    for (let holding_id in holding_records) {
      if (holding_id.startsWith('fake_id_')) {
        // In this case we cannot correlate the holding data from the availability API
        // (holding_records) with the holding data already on the page (from Solr).
        // In this case we set all of them to "Check record" because we can get this
        // information in the Show page.
        const badges = $(`*[data-availability-record='true'][data-record-id='${record_id}'] span.availability-icon`);
        badges.text("View record for Full Availability")
        return true;
      }

      // In Alma the label from the endpoint includes both the library name and the location.
      const availability_info = holding_records[holding_id];
      if (availability_info['label']) {
        const location = $(`*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location`);
        location.text(availability_info['label']);
      }
      const availability_element = $(`*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .availability-icon`);

      if (availability_info['temp_location']) {
        const current_map_link = $(`*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .find-it`);
        $(availability_element).next('.icon-warning').hide();
        const temp_map_link = this.stackmap_link(record_id, availability_info, true);
        current_map_link.replaceWith(temp_map_link);
      }
      this.apply_availability_label(availability_element, availability_info, true);
    }

    // Bib data does not know about bound-with records and therefore we don't get availability
    // information for holdings coming from the host record. For those holdings we ask the user
    // to check the record since in `process_single()` we do the extra work to get that information.
    const boundWithBadges = $(`*[data-availability-record='true'][data-record-id='${record_id}'][data-bound-with='true'] span.availability-icon`);
    boundWithBadges.text("View record for Full Availability")

    return true;
  }

  // process_single() is used in the Show page and typically `holding_records` only has the
  // information for a single bib since we are on the Show page. But occasionally the record
  // that we are showing is bound with another (host) record and in those instances
  // `holding_records` has data for two bibs: `this.id` and `this.host_id`.
  process_single(holding_records) {
    this.process_single_for_bib(holding_records, this.id)
    if (this.host_id !== "") {
      this.process_single_for_bib(holding_records, this.host_id)
    }
  }

  // process_single_for_bib() processes the data for a specific mms_id within the `holding_records`
  process_single_for_bib(holding_records, mms_id) {
    var dataComplete = true;
    for (let holding_id in holding_records[mms_id]) {
      const availability_info = holding_records[mms_id][holding_id];
      if ((availability_info['temp_location'] === true) && holding_id.startsWith('fake_id_')) {
        dataComplete = false; // The data that we get from Alma for temporary locations is incomplete.
        break;
      }
    }

    if (dataComplete) {
      // Update the page with the data that we already have.
      this.update_single(holding_records, mms_id);
      return;
    }

    // Make a separate call (with deep=true) to get more information before updating the page.
    var url = `${this.bibdata_base_url}/bibliographic/${mms_id}/availability.json?deep=true`;
    $.getJSON(url, (data) => { this.update_single(data, mms_id); })
      .fail((jqXHR, textStatus, errorThrown) => {
        return console.error(`Failed to retrieve deep availability data for bib. record ${mms_id}: ${errorThrown}`);
      });

    return;
  }

  update_single(holding_records, id) {
    return (() => {
      const result = [];
      for (let holding_id in holding_records[id]) {
        const availability_info = holding_records[id][holding_id];
        // Notice that the HTML element for availability uses the original MMS ID (this.id) in `data-record-id`
        // regardless of whether the holding is for the original MMS ID or for the host record (this.host_id).
        const availability_element = $(`*[data-availability-record='true'][data-record-id='${this.id}'][data-holding-id='${holding_id}'] .availability-icon`);
        if (availability_info['label']) {
          const holding_location = $(`*[data-location='true'][data-holding-id='${holding_id}']`);
          holding_location.text(availability_info['label']);
        }
        this.apply_availability_label(availability_element, availability_info, false);
        if (availability_info["cdl"]) {
          insert_online_link();
        }

        if (availability_info['temp_location']) {
          const current_map_link = $(`*[data-holding-id='${holding_id}'] .find-it`);
          const temp_map_link = this.stackmap_link(id, availability_info);
          current_map_link.replaceWith(temp_map_link);
        }

        result.push(this.update_request_button(holding_id, availability_info));
      }
      return result;
    })();
  }

  // Sets the availability badge to indicate that we are retrying to fetch the information
  update_availability_retrying() {
    var avBadges = $(`*[data-availability-record='true'] span.availability-icon`);
    $(avBadges).text("Loading...");
    $(avBadges).attr("title", "Fetching real-time availability");
    $(avBadges).addClass("badge badge-secondary");
  }

  // Sets the availability badge to indicate that we could not determine the availability
  update_availability_undetermined() {
    var avBadges = $(`*[data-availability-record='true'] span.availability-icon`);
    $(avBadges).text("Undetermined");
    $(avBadges).attr("title", "Cannot determine real-time availability for item at this time.");
    $(avBadges).addClass("badge badge-secondary");
  }

  process_scsb_single(item_records) {
    let availability_info, barcode, multi_items, status_message;
    if (Object.keys(item_records).length > 1) {
      multi_items = true;
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        if (availability_info['itemAvailabilityStatus'] !== 'Available') {
          status_message = 'Some Items Not Available';
        }
      }
    }
    return (() => {
      const result = [];
      for (barcode in item_records) {
        availability_info = item_records[barcode];
        const availability_element = $(`*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}'] .availability-icon`);
        const aeon = $(`*[data-availability-record='true'][data-record-id='${this.id}'][data-scsb-barcode='${barcode}']`).attr('data-aeon');
        availability_element.addClass("badge");
        if (aeon === 'true') {
          availability_element.addClass("badge-success");
          availability_element.text("On-Site Access");
          result.push(availability_element.attr("title", "Availability: On-site access by request"));
        } else if (multi_items) {
          if (status_message) {
            availability_element.addClass("badge-secondary");
            availability_element.text(status_message);
            result.push(availability_element.attr("title", "Availability: Some items not available"));
          } else {
            availability_element.addClass("badge-success");
            availability_element.text('All Items Available');
            result.push(availability_element.attr("title", "Availability: All items available"));
          }
        } else {
          if (availability_info['itemAvailabilityStatus'] === 'Available') {
            availability_element.addClass("badge-success");
            availability_element.text(availability_info['itemAvailabilityStatus']);
            result.push(availability_element.attr("title", "Availability: On shelf"));
          } else {
            availability_element.addClass("badge-danger");
            availability_element.text(availability_info['itemAvailabilityStatus']);
            result.push(availability_element.attr("title", "Availability: Checked out"));
          }
        }
      }
      return result;
    })();
  }

  record_ids() {
    return Array.from(
      document.querySelectorAll("*[data-availability-record='true'][data-record-id]")
    ).map(function(node) {
      return node.getAttribute("data-record-id")
    })
  }

  scsb_barcodes() {
    return Array.from(
      document.querySelectorAll("*[data-scsb-availability='true'][data-scsb-barcode]")
    ).map(function(node) {
      return node.getAttribute("data-scsb-barcode")
    })
  }

  update_request_button(holding_id, availability_info) {
    let availability_label_text;
    const location_services_element = $(`.location-services[data-holding-id='${holding_id}'] a`);
    const availability_label = $(`.holding-status[data-holding-id='${holding_id}'] .availability-icon.badge`);
    if (availability_label.text()) {
      availability_label_text = this.title_case(availability_label.text());
    }
    let display_request = location_services_element.attr('data-requestable');
    if (!Array.from(this.available_non_requestable_labels).includes(availability_label_text)) {
      display_request = 'true';
    }
    // if it's on CDL then it can't be requested
    if (availability_label_text === "Reserved for digital lending") {
      location_services_element.remove();
    }
    if (availability_info['on_reserve'] === 'Y') {
      return location_services_element.remove();
    }
    if (availability_info['status_label'].toLowerCase() === 'unavailable') {
      display_request = 'false';
    }
    if (display_request === 'true') {
      if (availability_info['temp_loc']) {
        return location_services_element.hide();
      } else {
        return location_services_element.show();
      }
    }
  }

  apply_scsb_record(barcode, item_data) {
    const availability_element = $(`*[data-scsb-availability='true'][data-scsb-barcode='${barcode}']`);
    if (item_data['itemAvailabilityStatus'] === 'Available') {
      availability_element.addClass("badge-success");
      availability_element.text(item_data['itemAvailabilityStatus']);
      availability_element.attr("title", "Availability: On Shelf");
    } else {
      availability_element.addClass("badge-danger");
      availability_element.text('Checked Out');
      availability_element.attr("title", "Availability: Checked Out");
    }
    return true;
  }

  apply_availability_label(availability_element, availability_info, addCdlBadge) {
    availability_element.addClass("badge");
    let status_label = availability_info['status_label'];
    let isCdl = availability_info['cdl'];
    let badgeClass = "badge-danger";
    status_label = `${status_label}${this.due_date(availability_info["due_date"])}`;
    availability_element.text(status_label);
    availability_element.attr('title', '');
    if (status_label.toLowerCase() === 'unavailable') {
      // The physical copy is not available but we highlight that the online copy is.
      if (isCdl) {
        if (addCdlBadge) {
          // Add an Online badge, next to Unavailable.
          // (used in the Search Results page)
          availability_element.addClass("badge-danger");
          availability_element.attr('title', 'Physical copy is not available.');

          let cdlPlaceholder = availability_element.parent().next().find("*[data-availability-cdl='true']");
          cdlPlaceholder.text('Online');
          cdlPlaceholder.attr('title', 'Online copy available via Controlled Digital Lending');
          cdlPlaceholder.addClass('badge badge-primary');
        } else {
          // Display Online, instead of Unavailable, and remove the request button.
          // (used in the Show page)
          availability_element.text('Online');
          availability_element.attr('title', 'Online copy available via Controlled Digital Lending');
          availability_element.addClass("badge-secondary");
          const location_services_element = $(`.location-services[data-holding-id='${availability_info['id']}'] a`);
          location_services_element.remove();
        }
      } else if (this.on_site_use_marquand_location(availability_info["location"])) {
        availability_element.text("Ask Staff");
        availability_element.attr('title', 'Ask a member of our staff for access to this item.');
        badgeClass = "badge-secondary"
      }
      else {
        availability_element.addClass("badge-danger");
      }
    } else if (status_label.toLowerCase() === 'available') {
      badgeClass = "badge-success";
    } else {
      badgeClass = "badge-secondary";
    }
    availability_element.addClass(badgeClass);
  }

  title_case(str) {
    return str[0].toUpperCase() + str.slice(1, +(str.length - 1) + 1 || undefined).toLowerCase();
  }

  stackmap_link(record_id, availability_info, marker_only) {
    let location;
    const temp_status = availability_info['temp_loc'];
    if (temp_status) {
      location = availability_info['temp_loc'];
    } else {
      location = availability_info['location'];
    }

    var link = '';
    if (this.find_it_location(location)) {
      const map_url = `/catalog/${record_id}/stackmap?loc=${location}`;
      const marker_span = "<span class='fa fa-map-marker'></span>";
      link = `<a title='Where to find it' class='find-it' data-location-map='${location}' data-blacklight-modal='trigger' href='${map_url}'>`;
      if (marker_only) {
        link = `${link}${marker_span}</a>`;
      } else {
        link = `${link}<span class='link-text'>Where to find it</span>${marker_span}</a>`;
      }
    }

    return link;
  };

  due_date(date_string) {
    if (date_string == null) { return ""; }
    return ` - ${date_string}`;
  };

  on_site_use_marquand_location(location) {
    return location == "marquand$stacks" || location == "marquand$pj";
  }

  /* Currently this logic is duplicated in Ruby code in application_helper.rb (ApplicationHelper::find_it_location) */
  find_it_location(location) {
    if (location.startsWith("plasma$") || location.startsWith("marquand$")) {
      return false
    }
    return true
  }
}

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
    this.availability_url = $("body").data("availability-base-url");
    this.id = '';

    this.on_site_status = 'On-site';
    this.on_site_unavailable = 'On-site - ';
    this.circ_desk = 'See front desk';
    this.available_statuses = ['Not charged', 'On shelf'];
    this.returned_statuses = ['Discharged'];
    this.in_process_statuses = ['In process', 'On-site - in process'];
    this.checked_out_statuses = ['Charged', 'Renewed', 'Overdue', 'On hold',
      'In transit', 'In transit on hold', 'In transit discharged', 'At bindery',
      'Remote storage request', 'Hold request', 'Recall request'];
    this.missing_statuses = ['Missing', 'Claims returned', 'Withdrawn',
      'On-site - missing', 'On-site - claims returned', 'On-site - withdrawn'];
    this.long_overdue_statuses = ['Lost--system applied', 'On-site - lost--system applied'];
    this.lost_statuses = ['Lost--library applied', 'On-site - lost--library applied'];
    this.available_labels = ['Available', 'Returned', 'In process', 'Requestable',
      'On shelf', 'All items available', 'On-site access'];
    this.available_non_requestable_labels = ['Available', 'Returned', 'Requestable',
      'On shelf', 'All items available', 'On-site access',
      'On-site - in-transit discharged', 'Reserved for digital lending'];
    this.open_location_labels = ['Available', 'All items available'];
    this.unavailable_labels = ['Checked out', 'Missing', 'Lost'];

    this.process_records = this.process_records.bind(this);
    this.process_barcodes = this.process_barcodes.bind(this);
    this.process_single = this.process_single.bind(this);
    this.process_scsb_single = this.process_scsb_single.bind(this);
  }

  request_availability() {
    let url;
    if ($(".documents-list").length > 0) {
      const ids = this.record_ids();
      if (ids.length < 1) { return; }
      const params = $.param({ids});
      url = `${this.availability_url}?${params}`;
      return $.getJSON(url, this.process_records)
        .fail((jqXHR, textStatus, errorThrown) => {
          return console.error(`Failed to retrieve availability data for the bib. records ${ids.join(", ")}: ${errorThrown}`);
        });

      // a show page
    } else if ($("*[data-availability-record='true']").length > 0) {
      this.id = window.location.pathname.split('/')[2];
      if (this.id.match(/^SCSB-\d+/)) {
        url = `${this.availability_url}?scsb_id=${this.id.replace(/^SCSB-/, '')}`;
        return $.getJSON(url, this.process_scsb_single)
          .fail((jqXHR, textStatus, errorThrown) => {
            return console.error(`Failed to retrieve availability data for the SCSB record ${id}: ${errorThrown}`);
          });

      } else {
        url = `${this.availability_url}?id=${this.id}`;
        return $.getJSON(url, this.process_single)
          .fail((jqXHR, textStatus, errorThrown) => {
            return console.error(`Failed to retrieve availability data for the bib. record ${id}: ${errorThrown}`);
          });
      }
    }
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

  process_records(records) {
    const result = [];
    for (let record_id in records) {
      const holding_records = records[record_id];
      result.push(this.apply_record(record_id, holding_records));
    }
    return result;
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

  process_single(holding_records) {
    return (() => {
      const result = [];
      for (let holding_id in holding_records) {
        const availability_info = holding_records[holding_id];
        const availability_element = $(`*[data-availability-record='true'][data-record-id='${this.id}'][data-holding-id='${holding_id}'] .availability-icon`);
        const aeon = $(`*[data-availability-record='true'][data-record-id='${this.id}'][data-holding-id='${holding_id}']`).attr('data-aeon');
        if (availability_info['label']) {
          const location = $(`*[data-location='true'][data-holding-id='${holding_id}']`);
          location.text(availability_info['label']);
        }
        if ($(".journal-current-issues").length > 0) { this.get_issues(holding_id); }
        if (availability_info['more_items']) {
          if (this.title_case(availability_info['status']).match(this.on_site_status)) {
            this.apply_record_icon(availability_element, "On-site access", aeon, availability_info);
          } else {
            this.apply_record_icon(availability_element, "All items available", aeon, availability_info);
          }
          this.get_more_items(holding_id, availability_info['label']);
        } else {
          if (availability_info["patron_group_charged"] === "CDL") {
            this.apply_record_icon(availability_element, "Reserved for Digital Lending" , aeon, availability_info);
            insert_online_link();
          } else {
            this.apply_record_icon(availability_element, availability_info['status'], aeon, availability_info);
          }
        }
        if (availability_info['temp_loc']) {
          const current_map_link = $(`*[data-holding-id='${holding_id}'] .find-it`);
          const temp_map_link = this.stackmap_link(this.id, availability_info);
          current_map_link.replaceWith(temp_map_link);
        }
        result.push(this.update_location_services(holding_id, availability_info));
      }
      return result;
    })();
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

  record_needs_more_info(record_id) {
    const element = $(`*[data-record-id='${record_id}'] .more-info`);
    element.addClass("badge badge-secondary");
    element.text("View record for full availability");
    element.attr('title', "Click on the record for full availability info");
    const empty = $(`*[data-record-id='${record_id}'].empty`);
    return empty.removeClass("empty");
  }

  get_issues(holding_id) {
    const url = `${this.availability_url}?mfhd_serial=${holding_id}`;
    const req = $.getJSON(url)
      .fail((jqXHR, textStatus, errorThrown) => {
        return console.error(`Failed to retrieve availability data for the serial holding ID/MFHD ${holding_id}: ${errorThrown}`);
      });

    const element = $(`*[data-journal='true'][data-holding-id='${holding_id}']`);
    return req.success(function(data) {
      if (data.length > 1) {
        element.before("<div class=\"holding-label current-issues\">Current issues</div>");
        element.after("<div class=\"trigger\">More</div>");
      } else if (data !== '') {
        element.before("<div class=\"holding-label current-issues\">Current issues</div>");
      }
      return (() => {
        const result = [];
        for (let key in data) {
          const issue = data[key];
          const li = $(`<li>${issue}</li>`);
          result.push(element.append(li));
        }
        return result;
      })();
    });
  }

  get_more_items(holding_id, holding_label) {
    const url = `${this.availability_url}?mfhd=${holding_id}`;
    const req = $.getJSON(url)
      .fail((jqXHR, textStatus, errorThrown) => {
        return console.error(`Failed to retrieve availability data for the holding ID ${holding_id}: ${errorThrown}`);
      });

    const element = $(`.item-status[data-holding-id='${holding_id}']`);
    return req.success(function(data) {
      let ul = "";
      for (let key in data) {
        var li;
        const item = data[key];
        const status = this.title_case(item['status']);
        const label = this.status_label(status);
        if ((holding_label !== item['label']) || item['temp_loc']) {
          li = `<li>${item['enum_display'] || 'Item'}: ${item['label']} - ${this.status_display(status, label)}</li>`;
          ul = ul + li;
        }
        if (!Array.from(this.available_statuses).includes(status) && (status !== this.on_site_status)) {
          if ((holding_label === item['label']) && !item['temp_loc']) {
            li = `<li>${item['enum_display'] || 'Item'}: ${this.status_display(status, label, item['due_date'])}</li>`;
            ul = ul + li;
          }
          const span = $(`*[data-holding-id='${holding_id}'] .availability-icon`);
          const txt = status.match(this.on_site_unavailable) ?
            this.circ_desk
            : !Array.from(this.unavailable_labels).includes(label) && (span.text() !== "Some items not available") ?
            "Some items may not be available"
            :
            "Some items not available";
          span.text(txt);
          span.attr("title", `Availability: ${txt}`);
          span.attr("data-original-title", `Availability: ${txt}`);
          if (!status.match(this.on_site_unavailable)) {
            span.removeClass("badge-success");
            span.addClass("badge-secondary");
            const location_services_element = $(`.location-services[data-holding-id='${holding_id}']`);
            location_services_element.show();
          }
        }
      }
      if (ul !== "") {
        element.before("<div class=\"holding-label item-status-label\">Item status</div>");
        return element.append(ul);
      }
    }.bind(this));
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

  update_location_services(holding_id, availability_info) {
    let availability_label_text;
    const status = availability_info['status'];
    const temp_status = availability_info['temp_loc'];
    const location_services_element = $(`.location-services[data-holding-id='${holding_id}'] a`);
    const availability_label = $(`.holding-status[data-holding-id='${holding_id}'] .availability-icon.badge`);
    if (availability_label.text()) {
      availability_label_text = this.title_case(availability_label.text());
    }
    let display_request = location_services_element.attr('data-requestable');
    if (!Array.from(this.available_non_requestable_labels).includes(availability_label_text)) {
      display_request = 'true';
    }
    if (availability_label_text === "Reserved for digital lending") {
      location_services_element.remove();
    }
    if (this.title_case(status) === 'On-site - in transit discharged') {
      display_request = 'false';
    }
    if (display_request === 'true') {
      if (temp_status) {
        return location_services_element.hide();
      } else {
        return location_services_element.show();
      }
    }
  }

  apply_record(record_id, holding_records) {
    for (let holding_id in holding_records) {
      var aeon;
      const availability_info = holding_records[holding_id];
      if (availability_info['label']) {
        const location = $(`*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location`);
        aeon = $(`*[data-record-id='${record_id}'][data-holding-id='${holding_id}']`).attr('data-aeon');
        location.text(availability_info['label']);
      }
      if (availability_info['more_items']) { this.record_needs_more_info(record_id); }
      const availability_element = $(`*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .availability-icon`);
      if (availability_info['temp_loc']) {
        const current_map_link = $(`*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .find-it`);
        $(availability_element).next('.icon-warning').hide();
        const temp_map_link = this.stackmap_link(record_id, availability_info, true);
        current_map_link.replaceWith(temp_map_link);
      }
      this.apply_record_icon(availability_element, availability_info['status'], aeon, {});
    }
    return true;
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

  apply_record_icon(availability_element, status, aeon, availability_info) {
    status = this.title_case(status);
    availability_element.addClass("badge");
    let label = this.status_label(status);
    if (!availability_info["patron_group_charged"] === "CDL") {
      label = `${label}${this.due_date(availability_info["due_date"])}`;
    }
    availability_element.text(label);
    if (Array.from(this.unavailable_labels).includes(label)) {
      availability_element.addClass("badge-danger");
    } else if (Array.from(this.available_labels).includes(label)) {
      availability_element.addClass("badge-success");
    } else if (label === 'On-site access') {
      availability_element.addClass("badge-warning");
    } else if (label === this.circ_desk) {
      availability_element.addClass("badge-warning");
    } else if (label === 'Online') {
      availability_element.addClass("badge-primary");
    } else {
      availability_element.addClass("badge-secondary");
    }
    if (aeon === 'true') {
      status = "On-site access by request";
    }
    availability_element.attr('title', `Availability: ${this.title_case(status)}`);
    availability_element.attr('data-original-title', `Availability: ${this.title_case(status)}`);
    return availability_element.attr('data-toggle', 'tooltip');
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
    const map_url = `/catalog/${record_id}/stackmap?loc=${location}`;
    let link = `<a title='Where to find it' class='find-it' data-location-map='${location}' data-blacklight-modal='trigger' href='${map_url}'>`;
    const marker_span = "<span class='fa fa-map-marker'></span>";
    if (marker_only) {
      link = `${link}${marker_span}</a>`;
    } else {
      link = `${link}<span class='link-text'>Where to find it</span>${marker_span}</a>`;
    }
    return link;
  };

  status_display(status, label, date_due) {
    if (status.match(label) || status.match(this.on_site_status)) {
      return status;
    } else {
      return `${label} ${this.due_date(date_due)} (${status})`;
    }
  };

  due_date(date_string) {
    if (date_string == null) { return ""; }
    return ` - ${date_string}`;
  };

  status_label(status) {
    switch (false) {
      case !Array.from(this.long_overdue_statuses).includes(status): return 'Long overdue';
      case !Array.from(this.lost_statuses).includes(status): return 'Lost';
      case !Array.from(this.available_statuses).includes(status): return 'Available';
      case !Array.from(this.returned_statuses).includes(status): return 'Returned';
      case status !== 'In transit discharged': return 'In transit';
      case !Array.from(this.in_process_statuses).includes(status): return 'In process';
      case !Array.from(this.checked_out_statuses).includes(status): return 'Checked out';
      case !Array.from(this.missing_statuses).includes(status): return 'Missing';
      case !status.match(this.on_site_unavailable): return this.circ_desk;
      case !status.match(this.on_site_status): return 'On-site access';
      case !status.match('Order received'): return 'Order received';
      case !status.match('Pending order'): return 'Pending order';
      case !status.match('On-order'): return 'On-order';
      default: return status;
    }
  };
}

export default class AvailabilityUpdater2 {

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
          li = `<li>${item['enum_display'] || 'Item'}: ${item['label']} - ${status_display(status, label)}</li>`;
          ul = ul + li;
        }
        if (!Array.from(this.available_statuses).includes(status) && (status !== this.on_site_status)) {
          if ((holding_label === item['label']) && !item['temp_loc']) {
            li = `<li>${item['enum_display'] || 'Item'}: ${status_display(status, label, item['due_date'])}</li>`;
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
    });
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
        const temp_map_link = stackmap_link(record_id, availability_info, true);
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
      label = `${label}${due_date(availability_info["due_date"])}`;
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

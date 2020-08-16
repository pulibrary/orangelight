/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$( document ).ready(function() {
  jQuery(() => window.availability_updater = new AvailabilityUpdater);
  var AvailabilityUpdater = (function() {
    let id = undefined;
    let on_site_status = undefined;
    let on_site_unavailable = undefined;
    let circ_desk = undefined;
    let available_statuses = undefined;
    let returned_statuses = undefined;
    let in_process_statuses = undefined;
    let checked_out_statuses = undefined;
    let missing_statuses = undefined;
    let long_overdue_statuses = undefined;
    let lost_statuses = undefined;
    let available_labels = undefined;
    let available_non_requestable_labels = undefined;
    let open_location_labels = undefined;
    let unavailable_labels = undefined;
    let status_display = undefined;
    let due_date = undefined;
    let stackmap_link = undefined;
    let au2 = undefined;
    AvailabilityUpdater = class AvailabilityUpdater {
      static initClass() {
        au2 = new AvailabilityUpdater2
        this.prototype.availability_url = $("body").data("availability-base-url");
        id = '';
        on_site_status = 'On-site';
        on_site_unavailable = 'On-site - ';
        circ_desk = 'See front desk';
        available_statuses = ['Not charged', 'On shelf'];
        returned_statuses = ['Discharged'];
        in_process_statuses = ['In process', 'On-site - in process'];
        checked_out_statuses = ['Charged', 'Renewed', 'Overdue', 'On hold',
          'In transit', 'In transit on hold', 'In transit discharged', 'At bindery',
          'Remote storage request', 'Hold request', 'Recall request'];
        missing_statuses = ['Missing', 'Claims returned', 'Withdrawn',
          'On-site - missing', 'On-site - claims returned', 'On-site - withdrawn'];
        long_overdue_statuses = ['Lost--system applied', 'On-site - lost--system applied'];
        lost_statuses = ['Lost--library applied', 'On-site - lost--library applied'];
        available_labels = ['Available', 'Returned', 'In process', 'Requestable',
          'On shelf', 'All items available', 'On-site access'];
        available_non_requestable_labels = ['Available', 'Returned', 'Requestable',
          'On shelf', 'All items available', 'On-site access', 'On-site - in-transit discharged', 'Reserved for digital lending'];
        open_location_labels = ['Available', 'All items available'];
        unavailable_labels = ['Checked out', 'Missing', 'Lost'];
        status_display = function(status, label, date_due) {
          if (status.match(label) || status.match(on_site_status)) {
            return status;
          } else {
            return `${label} ${due_date(date_due)} (${status})`;
          }
        };
        due_date = function(date_string) {
          if (date_string == null) { return ""; }
          return ` - ${date_string}`;
        };
        stackmap_link = function(record_id, availability_info, marker_only) {
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
      }

      constructor() {
        this.process_records = this.process_records.bind(this);
        this.process_barcodes = this.process_barcodes.bind(this);
        this.process_single = this.process_single.bind(this);
        this.process_scsb_single = this.process_scsb_single.bind(this);
        this.request_availability();
        this.scsb_search_availability();
      }

      request_availability() {
        let url;
        if ($(".documents-list").length > 0) {
          const ids = au2.record_ids();
          if (ids.length < 1) { return; }
          const params = $.param({ids});
          url = `${this.availability_url}?${params}`;
          return $.getJSON(url, this.process_records)
            .fail((jqXHR, textStatus, errorThrown) => {
              return console.error(`Failed to retrieve availability data for the bib. records ${ids.join(", ")}: ${errorThrown}`);
            });

          // a show page
        } else if ($("*[data-availability-record='true']").length > 0) {
          id = window.location.pathname.split('/')[2];
          if (id.match(/^SCSB-\d+/)) {
            url = `${this.availability_url}?scsb_id=${id.replace(/^SCSB-/, '')}`;
            return $.getJSON(url, this.process_scsb_single)
              .fail((jqXHR, textStatus, errorThrown) => {
                return console.error(`Failed to retrieve availability data for the SCSB record ${id}: ${errorThrown}`);
              });

          } else {
            url = `${this.availability_url}?id=${id}`;
            return $.getJSON(url, this.process_single)
              .fail((jqXHR, textStatus, errorThrown) => {
                return console.error(`Failed to retrieve availability data for the bib. record ${id}: ${errorThrown}`);
              });
          }
        }
      }

      scsb_search_availability() {
        if ($(".documents-list").length > 0) {
          const barcodes = au2.scsb_barcodes();
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
        return (() => {
          const result = [];
          for (let record_id in records) {
            const holding_records = records[record_id];
            result.push(au2.apply_record(record_id, holding_records));
          }
          return result;
        })();
      }

      process_barcodes(barcodes) {
        return (() => {
          const result = [];
          for (let barcode_id in barcodes) {
            const item_data = barcodes[barcode_id];
            result.push(au2.apply_scsb_record(barcode_id, item_data));
          }
          return result;
        })();
      }

      process_single(holding_records) {
        return (() => {
          const result = [];
          for (let holding_id in holding_records) {
            const availability_info = holding_records[holding_id];
            const availability_element = $(`*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}'] .availability-icon`);
            const aeon = $(`*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}']`).attr('data-aeon');
            if (availability_info['label']) {
              const location = $(`*[data-location='true'][data-holding-id='${holding_id}']`);
              location.text(availability_info['label']);
            }
            if ($(".journal-current-issues").length > 0) { au2.get_issues(holding_id); }
            if (availability_info['more_items']) {
              if (au2.title_case(availability_info['status']).match(on_site_status)) {
                au2.apply_record_icon(availability_element, "On-site access", aeon, availability_info);
              } else {
                au2.apply_record_icon(availability_element, "All items available", aeon, availability_info);
              }
              au2.get_more_items(holding_id, availability_info['label']);
            } else {
              if (availability_info["patron_group_charged"] === "CDL") {
                au2.apply_record_icon(availability_element, "Reserved for Digital Lending" , aeon, availability_info);
                this.insert_online_link();
              } else {
                au2.apply_record_icon(availability_element, availability_info['status'], aeon, availability_info);
              }
            }
            if (availability_info['temp_loc']) {
              const current_map_link = $(`*[data-holding-id='${holding_id}'] .find-it`);
              const temp_map_link = stackmap_link(id, availability_info);
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
            const availability_element = $(`*[data-availability-record='true'][data-record-id='${id}'][data-scsb-barcode='${barcode}'] .availability-icon`);
            const aeon = $(`*[data-availability-record='true'][data-record-id='${id}'][data-scsb-barcode='${barcode}']`).attr('data-aeon');
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

      update_location_services(holding_id, availability_info) {
        let availability_label_text;
        const status = availability_info['status'];
        const temp_status = availability_info['temp_loc'];
        const location_services_element = $(`.location-services[data-holding-id='${holding_id}'] a`);
        const availability_label = $(`.holding-status[data-holding-id='${holding_id}'] .availability-icon.badge`);
        if (availability_label.text()) {
          availability_label_text = au2.title_case(availability_label.text());
        }
        let display_request = location_services_element.attr('data-requestable');
        if (!Array.from(available_non_requestable_labels).includes(availability_label_text)) {
          display_request = 'true';
        }
        if (availability_label_text === "Reserved for digital lending") {
          location_services_element.remove();
        }
        if (au2.title_case(status) === 'On-site - in transit discharged') {
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

      insert_online_link() {
        let online_div = $(".availability--online:visible");
        if (online_div.length < 1) {
          const physical_div = $(".availability--physical");
          online_div = '<div class="availability--online"><h3>Available Online</h3><ul><li>Princeton users: <a href="#view">View digital content</a></li></ul></div>';
          return $(online_div).insertBefore(physical_div);
        }
      }


    };
    AvailabilityUpdater.initClass();
    return AvailabilityUpdater;
  })();
});

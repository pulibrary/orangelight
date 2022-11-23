/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import { insert_online_link } from './insert_online_link.es6';

export default class AvailabilityUpdater {

    constructor() {
        this.bibdata_base_url = $("body").data("bibdata-base-url");
        this.availability_url = `${this.bibdata_base_url}/availability`;
        this.id = '';
        this.host_id = '';

        this.process_results_list = this.process_results_list.bind(this);
        this.process_barcodes = this.process_barcodes.bind(this);
        this.process_single = this.process_single.bind(this);
        this.update_single = this.update_single.bind(this);
        this.update_availability_undetermined = this.update_availability_undetermined.bind(this);
        this.process_scsb_single = this.process_scsb_single.bind(this);
        this.availability_url_show = this.availability_url_show.bind(this);
    }

    request_availability(allowRetry) {
        // a search results page or a call number browse page
        if ($(".documents-list").length > 0) {
            const bib_ids = this.record_ids();
            if (bib_ids.length < 1) {
                return;
            }

            const batch_size = 10;
            const batches = this.ids_to_batches(bib_ids, batch_size);
            console.log(`Requested at ${new Date().toISOString()}, batch size: ${batch_size}, batches: ${batches.length}, ids: ${bib_ids.length}`);

            for(let i= 0; i < batches.length; i++) {
                const batch_url = `${this.bibdata_base_url}/bibliographic/availability.json?bib_ids=${batches[i].join()}`;
                console.log(`batch: ${i}, url: ${batch_url}`);
                fetch(batch_url)
                    .then(function(response) {
                        if (!response.ok) {
                            throw Error(response.statusText);
                        }
                        return response; })
                    .then((response) => response.json())
                    .then((data) => this.process_results_list(data))
                    .catch(error => {
                        // handle the error
                        console.log(`Failed to retrieve availability data for batch. Error: ${error}`);
                    });
            }

            // a show page
        } else if ($("*[data-availability-record='true']").length > 0) {
            this.id = window.location.pathname.split('/').pop();
            this.host_id = $("#main-content").data("host-id") || "";
            if (this.id.match(/^SCSB-\d+/)) {
                const url = `${this.availability_url}?scsb_id=${this.id.replace(/^SCSB-/, '')}`;
                return fetch(url)
                    .then(function(response) {
                        if (!response.ok) {
                            throw Error(response.statusText);
                        }
                        return response; })
                    .then((response) => response.json())
                    .then((data) => this.process_scsb_single(data))
                    .catch(error => {
                        console.log(`Failed to retrieve availability data for the SCSB record ${this.id}: Error: ${error}`);
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
    
    // handleErrors(response) {
    //     if (!response.ok) {
    //         throw Error(response.statusText);
    //     }
    //     return response;
    // };

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
                // This holding location should always show as unavailable
                const badges = $(`*[data-availability-record='true'][data-record-id='${record_id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] span.availability-icon`);
                badges.addClass("badge-danger");
                badges.text("Unavailable");
                return true;
            }
            if (holding_id.match(/[a-zA-Z]\$[a-zA-Z]/)) {
                // In this case we cannot correlate the holding data from the availability API
                // (holding_records) with the holding data already on the page (from Solr).
                // In this case we set all of them to "View record for Full Availability" because we can get this
                // information in the Show page.
                const badges = $(`*[data-availability-record='true'][data-record-id='${record_id}'] span.availability-icon`);
                badges.text("View record for Full Availability");
                return true;
            }

            // In Alma the label from the endpoint includes both the library name and the location.
            const availability_info = holding_records[holding_id];
            const {label, temp_location} = availability_info;
            if (label) {
                const location = $(`*[data-location='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .results_location`);
                location.text(label);
            }
            const availability_element = $(`*[data-availability-record='true'][data-record-id='${record_id}'][data-holding-id='${holding_id}'] .availability-icon`);

            if (temp_location) {
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
        boundWithBadges.text("View record for Full Availability");

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
                const { label, cdl, temp_location } = holding_records[id][holding_id];
                // case :constituent with host ids.
                // data-record-id has a different this.id when there are host ids.
                let availability_element;

                // If we are not getting holding info select the availability element by record id only.
                if (holding_id == 'RES_SHARE$IN_RS_REQ') {
                    availability_element = $(`*[data-availability-record='true'][data-record-id='${id}'][data-temp-location-code='RES_SHARE$IN_RS_REQ'] .availability-icon`);
                } else {
                    availability_element = $(`*[data-availability-record='true'][data-record-id='${id}'][data-holding-id='${holding_id}'] .availability-icon`);
                }
                if (label) {
                    const holding_location = $(`*[data-location='true'][data-holding-id='${holding_id}']`);
                    holding_location.text(label);
                }
                this.apply_availability_label(availability_element, availability_info, false);
                if (cdl) {
                    insert_online_link();
                }

                if (temp_location) {
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
        const avBadges = $(`*[data-availability-record='true'] span.availability-icon`);
        $(avBadges).text("Loading...");
        $(avBadges).attr("title", "Fetching real-time availability");
        $(avBadges).addClass("badge badge-secondary");
    }

    // Sets the availability badge to indicate that we could not determine the availability
    update_availability_undetermined() {
        const avBadges = $(`*[data-availability-record='true'] span.availability-icon`);
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
            return node.getAttribute("data-record-id");
        });
    }

    ids_to_batches(ids, batch_size) {
        const batches = [];
        const batch_count = Math.floor(ids.length / batch_size) + (ids.length % batch_size);
        let i, begin, end, batch;
        for (i=0; i < batch_count; i++) {
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
            document.querySelectorAll("*[data-scsb-availability='true'][data-scsb-barcode]")
        ).map(function(node) {
            return node.getAttribute("data-scsb-barcode");
        });
    }

    update_request_button(holding_id, availability_info) {
        const { cdl } = availability_info;
        const location_services_element = $(`.location-services[data-holding-id='${holding_id}'] a`);
        // if it's on CDL then it can't be requested
        if (cdl) {
            location_services_element.remove();
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
        const { status_label, cdl, location, id } = availability_info;
        const specialStatusLocations = ["marquand$stacks", "marquand$pj", "marquand$ref","marquand$ph", "marquand$fesrf", "RES_SHARE$IN_RS_REQ"];
        availability_element.text(status_label);
        availability_element.attr('title', '');
        if (status_label.toLowerCase() === 'unavailable') {
            // The physical copy is not available but we highlight that the online copy is.
            if (cdl) {
                if (addCdlBadge) {
                    // Add an Online badge, next to Unavailable.
                    // (used in the Search Results page)
                    availability_element.addClass("badge-danger");
                    availability_element.attr('title', 'Physical copy is not available.');

                    const cdlPlaceholder = availability_element.parent().next().find("*[data-availability-cdl='true']");
                    cdlPlaceholder.text('Online');
                    cdlPlaceholder.attr('title', 'Online copy available via Controlled Digital Lending');
                    cdlPlaceholder.addClass('badge badge-primary');
                } else {
                    // Display Online, instead of Unavailable, and remove the request button.
                    // (used in the Show page)
                    availability_element.text('Online');
                    availability_element.attr('title', 'Online copy available via Controlled Digital Lending');
                    availability_element.addClass("badge-secondary");
                    const location_services_element = $(`.location-services[data-holding-id='${id}'] a`);
                    location_services_element.remove();
                }
            } else if (specialStatusLocations.includes(location)) {
                this.checkSpecialLocation(location, availability_element);
            }
            else {
                availability_element.addClass("badge-danger");
            }
        } else if (status_label.toLowerCase() === 'available') {
            availability_element.addClass("badge-success");
        } else {
            availability_element.addClass("badge-secondary");
        }
        return availability_element;
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

        let link = '';
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
    }
  
    // Set status for specific Marquand locations and location RES_SHARE$IN_RS_REQ
    checkSpecialLocation(location, availability_element) {
        if (location.startsWith("marquand$")){
            availability_element.text("Ask Staff").attr('title', 'Ask a member of our staff for access to this item.').addClass("badge-secondary");
        } else {
            availability_element.text("Unavailable").attr('title', 'Unavailable').addClass("badge-danger");
        }
        return availability_element;
    }

    /* Currently this logic is duplicated in Ruby code in application_helper.rb (ApplicationHelper::find_it_location) */
    find_it_location(location) {
        if (location.startsWith("plasma$") || location.startsWith("marquand$")) {
            return false;
        }
        return true;
    }
}

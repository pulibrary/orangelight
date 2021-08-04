import updater from 'orangelight/availability'
import { promises as fs } from 'fs';
import * as orangelight_online_link from '../../../app/javascript/orangelight/insert_online_link'

describe('AvailabilityUpdater', function() {
  test('hooked up right', () => {
    expect(updater).not.toBe(undefined)
  })

  test('search results page with available, unavailable, mixed holdings display desired labels and badges', async () => {
    const avail_id = "99120385083506421"
    const unavail_id = "99121744283506421"
    const mixed_id = "99119590233506421"
    document.body.innerHTML =
      '<div id="documents" class="documents-list">' +
        '<article>' +
          '<div class="row">' +
            '<div class="record-wrapper">' +
              '<ul class="document-metadata dl-horizontal dl-invert">' +
                '<li class="blacklight-holdings">' +
                  '<ul>' +
                    `<li data-availability-record="true" data-record-id="${avail_id}" data-holding-id="2224357860006421" data-aeon="false"><span class="availability-icon"></span></li>` +
                  '</ul>' +
                '</li>' +
              '</ul>' +
            '</div>' +
          '</div>' +
        '</article>' +
        '<article>' +
          '<div class="row">' +
            '<div class="record-wrapper">' +
              '<ul class="document-metadata dl-horizontal dl-invert">' +
                '<li class="blacklight-holdings">' +
                  '<ul>' +
                    `<li data-availability-record="true" data-record-id="${unavail_id}" data-holding-id="2278269270006421" data-aeon="false"><span class="availability-icon"></span></li>` +
                  '</ul>' +
                '</li>' +
              '</ul>' +
            '</div>' +
          '</div>' +
        '</article>' +
        '<article>' +
          '<div class="row">' +
            '<div class="record-wrapper">' +
              '<ul class="document-metadata dl-horizontal dl-invert">' +
                '<li class="blacklight-holdings">' +
                  '<ul>' +
                    `<li data-availability-record="true" data-record-id="${mixed_id}" data-holding-id="22186788410006421" data-aeon="false"><span class="availability-icon"></span></li>` +
                  '</ul>' +
                '</li>' +
              '</ul>' +
            '</div>' +
          '</div>' +
        '</article>' +
      '</div>'
    let bibdata_response = await fs.readFile("spec/fixtures/bibliographic_availability_3_bibs.json", 'utf8')
    bibdata_response = JSON.parse(bibdata_response)

    let u = new updater
    u.process_results_list(bibdata_response)

    const available_result = $(`*[data-record-id="${avail_id}"] .availability-icon`)
    expect(available_result.hasClass('badge')).toBe(true)
    expect(available_result.hasClass('badge-success')).toBe(true)
    expect(available_result.text()).toEqual("Available")

    const unavailable_result = $(`*[data-record-id="${unavail_id}"] .availability-icon`)
    expect(unavailable_result.hasClass('badge')).toBe(true)
    expect(unavailable_result.hasClass('badge-danger')).toBe(true)
    expect(unavailable_result.text()).toEqual("Unavailable")

    const mixed_result = $(`*[data-record-id="${mixed_id}"] .availability-icon`)
    expect(mixed_result.hasClass('badge')).toBe(true)
    expect(mixed_result.hasClass('badge-secondary')).toBe(true)
    expect(mixed_result.text()).toEqual("Some items not available")
  })

  test('search results availability for records in temporary locations says Check Record', () => {
    document.body.innerHTML =
      '<li class="blacklight-holdings">' +
      '    <ul>' +
      '        <li data-availability-record="true" data-record-id="9959958323506421" data-holding-id="22272063570006421" data-aeon="false">' +
      '            <span class="availability-icon badge badge-secondary">Loading...</span>' +
      '            <div class="library-location" data-location="true" data-record-id="9959958323506421" data-holding-id="22272063570006421">' +
      '                <span class="results_location">Lewis Library - Lewis Library</span> &raquo; ' +
      '                <span class="call-number">QC33 .M52 2003 ' +
      '                    <a title="Where to find it" class="find-it" data-map-location="lewis$stacks" data-blacklight-modal="trigger" aria-label="Where to find it" href="...">' +
      '                        <span class="fa fa-map-marker" aria-hidden="true"></span>' +
      '                    </a>' +
      '                </span>' +
      '            </div>' +
      '        </li>' +
      '        <li data-availability-record="true" data-record-id="9959958323506421" data-holding-id="22272063520006421" data-aeon="false">' +
      '            <span class="availability-icon badge badge-secondary">Loading...</span>' +
      '            <div class="library-location" data-location="true" data-record-id="9959958323506421" data-holding-id="22272063520006421">' +
      '                <span class="results_location">Lewis Library - Lewis Library</span> &raquo; ' +
      '                <span class="call-number">QC33 .M52 2003 ' +
      '                    <a title="Where to find it" class="find-it" data-map-location="lewis$stacks" data-blacklight-modal="trigger" aria-label="Where to find it" href="...">' +
      '                        <span class="fa fa-map-marker" aria-hidden="true"></span>' +
      '                    </a>' +
      '                </span>' +
      '            </div>' +
      '        </li>' +
      '        <li class="empty" data-record-id="9959958323506421">' +
      '            <a class="availability-icon more-info" title="Click on the record for full availability info" data-toggle="tooltip" href="/catalog/9959958323506421"></a>' +
      '        </li>' +
      '    </ul>' +
      '</li>'

    const apiResponse = {
      "9959958323506421": {
        "fake_id_1": {
          "on_reserve":"Y",
          "location":"lewis$resterm",
          "label":"Lewis Library - sciresp Lewis: Term Loan",
          "status_label":"Available",
          "copy_number":null,
          "cdl":false,
          "temp_location":true,
          "id":"fake_id_1"
        }
      }
    }


    const badgesBefore = document.getElementsByClassName('availability-icon')
    expect(badgesBefore[0].textContent).toEqual('Loading...')

    const bibId = '9959958323506421'
    const holdingData = apiResponse[bibId]
    let u = new updater
    u.process_result(bibId, holdingData)

    const badgesAfter = document.getElementsByClassName('availability-icon')
    expect(badgesAfter[0].textContent).toEqual('View record for availability')
  })

  test('record show page with an available holding displays the status label in green', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="99118400923506421" data-holding-id="22105449840006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"99118400923506421":{"22105449840006421":{"on_reserve":"N","location":"stacks","label":"Firestone Library (F)","status_label":"Available","more_items":false,"holding_type":"physical","id":"22105449840006421"}}}
    let u = new updater
    u.id = '99118400923506421'
    u.process_single(holding_records)

    const badge = document.getElementsByClassName('availability-icon')[0]

    expect(badge.classList.values()).toContain('badge')
    expect(badge.classList.values()).toContain('badge-success')
    expect(badge.textContent).toEqual('Available')
  })

  test('record show page with an unavailable holding displays the status label in red', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="99118400923506421" data-holding-id="22105449840006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"99118400923506421":{"22105449840006421":{"on_reserve":"N","location":"stacks","label":"Firestone Library (F)","status_label":"Unavailable","more_items":false,"holding_type":"physical","id":"22105449840006421"}}}
    let u = new updater
    u.id = '99118400923506421'
    u.process_single(holding_records)

    const badge = document.getElementsByClassName('availability-icon')[0]

    expect(badge.classList.values()).toContain('badge')
    expect(badge.classList.values()).toContain('badge-danger')
    expect(badge.textContent).toEqual('Unavailable')
  })

  test('record show page with an mixed availability holding displays the status label in gray', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="99118400923506421" data-holding-id="22105449840006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"99118400923506421":{"22105449840006421":{"on_reserve":"N","location":"stacks","label":"Firestone Library (F)","status_label":"Some items not available","more_items":false,"holding_type":"physical","id":"22105449840006421"}}}
    let u = new updater
    u.id = '99118400923506421'
    u.process_single(holding_records)

    const badge = document.getElementsByClassName('availability-icon')[0]

    expect(badge.classList.values()).toContain('badge')
    expect(badge.classList.values()).toContain('badge-secondary')
    expect(badge.textContent).toEqual('Some items not available')
  })

  test('record show page with an item on CDL adds link to viewer', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9965126093506421" data-holding-id="22202918790006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"9965126093506421":{"22202918790006421":{"on_reserve":"N","location":"firestone$stacks","label":"Stacks","status_label":"Unavailable","cdl":true,"holding_type":"physical","id":"22202918790006421"}}}

    const spy = jest.spyOn(orangelight_online_link, 'insert_online_link')

    let u = new updater
    u.id = '9965126093506421'
    u.process_single(holding_records)

    expect(spy).toHaveBeenCalled()
    spy.mockRestore()
  })

  // Make sure that the code to handle undetermined availability status updates
  // the HTML correctly.
  test('undetermined availability for show page', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9965126093506421" data-holding-id="22202918790006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';

    let u = new updater
    u.id = '9965126093506421'
    u.update_availability_undetermined();

    expect(document.body.innerHTML).toContain("Undetermined");
  })

  test('when record has temporary locations and complete data', () => {
    const holding_records = {
      "9959958323506421": {
        "22272063570006421": {
          "on_reserve": "N",
          "location": "lewis$resterm",
          "label": "sciresp: Lewis: Term Loan",
          "status_label": "Available",
          "copy_number": "1",
          "cdl": false,
          "temp_location": true,
          "id": "22272063570006421"
        }
      }
    }

    // We expect to call update_single
    let u = new updater
    u.id = '9959958323506421'
    const update_single = jest.spyOn(u, 'update_single')
    u.process_single(holding_records)
    expect(update_single).toHaveBeenCalledWith(holding_records, u.id)
    update_single.mockRestore()
  })

  test('when record has temporary locations and incomplete data it makes an extra call to get the full data', () => {
    const holding_records = {
      "9959958323506421": {
        "fake_id_1": {
          "on_reserve": "N",
          "location": "lewis$resterm",
          "label": "sciresp: Lewis: Term Loan",
          "status_label": "Available",
          "copy_number": "1",
          "cdl": false,
          "temp_location": true,
          "id": "fake_id_1"
        }
      }
    }

    // We expect an AJAX call to bib data but with the `deep=true` parameter.
    // Notice that we are not testing that it calls `update_single` when the AJAX call completes
    // (since we are mocking the AJAX call) but there are other tests that take care of that.
    // Not ideal but good enough.
    let u = new updater
    u.bibdata_base_url = 'http://mock_url'
    u.id = '9959958323506421'
    const getJSON = jest.spyOn($, 'getJSON')
    u.process_single(holding_records)
    expect(getJSON).toHaveBeenCalledWith("http://mock_url/bibliographic/9959958323506421/availability.json?deep=true", expect.any(Function) )
    getJSON.mockRestore()
  })

  test('record show page with an item not on CDL does not add a link', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9965126093506421" data-holding-id="22202918790006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"9965126093506421":{"22202918790006421":{"on_reserve":"N","location":"firestone$stacks","label":"Stacks","status_label":"Unavailable","cdl":false,"holding_type":"physical","id":"22202918790006421"}}}

    const spy = jest.spyOn(orangelight_online_link, 'insert_online_link')

    let u = new updater
    u.id = '9965126093506421'
    u.process_single(holding_records)

    expect(spy).not.toHaveBeenCalled()
    spy.mockRestore()
  })

  test('record show page for a bound-with record', () => {
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9929455793506421" data-holding-id="22269289940006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {
      "9929455793506421":{},
      "99121886293506421":{"22269289940006421":{"on_reserve":"N","location":"recap$pa","label":"ReCAP - ReCAP - rcppa RECAP","status_label":"Available","copy_number":null,"cdl":false,"temp_location":false,"id":"22269289940006421"}}
    }

    let u = new updater
    u.id = '9929455793506421'         // contained bib
    u.host_id = '99121886293506421'   // host bib

    const process_single_for_bib = jest.spyOn(u, 'process_single_for_bib')
    u.process_single(holding_records)

    expect(process_single_for_bib).toHaveBeenCalledWith(holding_records, u.id)
    expect(process_single_for_bib).toHaveBeenCalledWith(holding_records, u.host_id)
    process_single_for_bib.mockRestore()
  })


  test('record search results page for a bound-with record', () => {
    // Notice the data-bound-with="true"
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9929455793506421" data-holding-id="22269289940006421" data-aeon="false" data-bound-with="true">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {"9929455793506421":{}}
    const holding_badge = $("*[data-availability-record='true'][data-record-id='9929455793506421'][data-bound-with='true'] span.availability-icon")[0];

    let u = new updater
    u.process_result("9929455793506421", holding_records)

    expect(holding_badge.textContent).toContain('View record for availability');
  })

  test('extra Online availability added for CDL records that are reported as unavailable', () => {
    document.body.innerHTML = '<ul>'+
      '  <li data-availability-record="true" data-record-id="9965126093506421" data-holding-id="22202918790006421" data-aeon="false">' +
      '    <span class="availability-icon"></span>' +
      '    <div class="library-location" data-location="true" data-record-id="9965126093506421" data-holding-id="22202918790006421">' +
      '      <span class="results_location">Firestone Library - Stacks</span> » ' +
      '      <span class="call-number">PS3558.A62424 B43 2010 ' +
      '        <a title="Where to find it" class="find-it" data-map-location="firestone$stacks" data-blacklight-modal="trigger" ' +
      '           aria-label="Where to find it" href="/catalog/9965126093506421/stackmap?loc=firestone$stacks&amp;cn=PS3558.A62424 B43 2010">' +
      '          <span class="fa fa-map-marker" aria-hidden="true"></span>' +
      '        </a>' +
      '      </span>' +
      '    </div>' +
      '  </li>' +
      '  <li>' +
      '    <span class="badge badge-primary" data-availability-cdl="true"></span>' +
      '  </li>' +
      '  <li class="empty" data-record-id="9965126093506421">' +
      '    <a class="availability-icon more-info" title="Click on the record for full availability info" data-toggle="tooltip" href="/catalog/9965126093506421"></a>' +
      '  </li>' +
      '</ul>';

    const availability_response = {
      "9965126093506421" : {
        "22202918790006421" : {
          "on_reserve": "N",
          "location": "firestone$stacks",
          "label": "Firestone Library - Stacks",
          "status_label": "Unavailable",
          "copy_number": null,
          "cdl": true,
          "temp_location": false,
          "id": "22202918790006421"
        }
      }
    };
    const holding_data = availability_response["9965126093506421"]["22202918790006421"];

    const cdl_element = $("*[data-availability-cdl='true']")[0];
    const av_element = $(`*[data-availability-record='true'][data-record-id='9965126093506421'][data-holding-id='22202918790006421'] .availability-icon`);

    let u = new updater;
    u.id = '9965126093506421';

    expect(cdl_element.textContent).not.toContain('Online');
    u.apply_availability_label(av_element, holding_data, true);
    expect(cdl_element.textContent).toContain('Online');
  })

  // TODO: This method isn't covered by the feature tests
  test('scsb_barcodes() on a search results page', () => {
    // This is only used on search results page
    // show pages use `data-availability-record` for scsb barcodes
    // browse pages don't run availability for scsb items
    document.body.innerHTML =
      '<article>' +
      '  <div class="row">' +
      '    <div class="record-wrapper">' +
      '      <ul class="document-metadata dl-horizontal dl-invert">' +
      '        <li class="blacklight-holdings"><ul><li data-availability-record="false" data-record-id="SCSB-8562843" data-holding-id="8720897" data-aeon="false"><span class="availability-icon badge" title data-scsb-availability="true" data-toggle="tooltip" data-scsb-barcode="33433038233809"></span></li>' +
      '      </ul>' +
      '    </div>' +
      '  </div>' +
      '</article>'
    let u = new updater
    expect(u.scsb_barcodes()).toEqual(['33433038233809'])
  })

  test('record_ids() on a search results page', () => {
    document.body.innerHTML =
      '<div id="documents" class="documents-list">' +
        '<article>' +
          '<div class="row">' +
            '<div class="record-wrapper">' +
              '<ul class="document-metadata dl-horizontal dl-invert">' +
                '<li class="blacklight-holdings">' +
                  '<ul>' +
                    '<li data-availability-record="true" data-record-id="10585552" data-holding-id="10329434" data-aeon="false"></li>' +
                  '</ul>' +
                '</li>' +
              '</ul>' +
            '</div>' +
          '</div>' +
        '</article>' +
        '<article>' +
          '<div class="row">' +
            '<div class="record-wrapper">' +
              '<ul class="document-metadata dl-horizontal dl-invert">' +
                '<li class="blacklight-holdings">' +
                  '<ul>' +
                    '<li data-availability-record="true" data-record-id="7058493" data-holding-id="6938508" data-aeon="false">' +
                  '</ul>' +
                '</li>' +
              '</ul>' +
            '</div>' +
          '</div>' +
        '</article>' +
      '</div>'
    let u = new updater
    expect(u.record_ids()).toEqual(['10585552', '7058493'])
  })

  test('record_ids() on a call number browse page', () => {
    document.body.innerHTML =
      '<table><tbody>' +
      '  <tr>' +
      '    <td class="availability-column" data-availability-record="true" data-record-id="2939035" data-holding-id="3253750"></td>' +
      '  </tr>' +
      '    <td class="availability-column" data-availability-record="true" data-record-id="3821268" data-holding-id="4126404"></td>' +
      '  <tr>' +
      '  </tr>' +
      '</table></tbody>'
    let u = new updater
    expect(u.record_ids()).toEqual(['2939035', '3821268'])
  })

  test('account for bound-with records when building URL to request availability', () => {
    let u = new updater
    u.bibdata_base_url = 'http://mock_url'
    u.id = '9965126093506421'
    expect(u.availability_url_show()).toEqual('http://mock_url/bibliographic/availability.json?deep=true&bib_ids=9965126093506421')

    u.host_id = '9900126093506421'
    expect(u.availability_url_show()).toEqual('http://mock_url/bibliographic/availability.json?deep=true&bib_ids=9965126093506421,9900126093506421')
  })

  test('does not display Request button for items on reserves', () => {
    document.body.innerHTML =
      '<h3>Copies in the Library</h3>' +
      '<table class="availability-table">' +
      '    <tbody>' +
      '        <tr class="holding-block">' +
      '            <td class="library-location" data-holding-id="22614245530006421"><span class="location-text"' +
      '                    data-location="true" data-holding-id="22614245530006421">Firestone Library - Stacks</span> <a' +
      '                    title="Where to find it" class="find-it" data-map-location="firestone$stacks"' +
      '                    data-blacklight-modal="trigger" data-call-number="HB172.5 .B38 2020"' +
      '                    data-library="Firestone Library"' +
      '                    href="/catalog/99115992283506421/stackmap?loc=firestone$stacks&amp;cn=HB172.5 .B38 2020"><span' +
      '                        class="link-text">Where to find it</span> <span class="fa fa-map-marker"' +
      '                        aria-hidden="true"></span></a></td>' +
      '            <td class="holding-call-number">HB172.5 .B38 2020 <a class="browse-cn" title="Browse: HB172.5 .B38 2020"' +
      '                    data-toggle="tooltip" data-original-title="Browse: HB172.5 .B38 2020"' +
      '                    href="/browse/call_numbers?q=HB172.5+.B38+2020"><span class="link-text">Browse related items</span>' +
      '                    <span class="icon-bookslibrary"></span></a></td>' +
      '            <td class="holding-status" data-availability-record="true" data-record-id="99115992283506421"' +
      '                data-holding-id="22614245530006421" data-aeon="false"><span class="availability-icon"></span></td>' +
      '            <td class="location-services service-conditional" data-open="true" data-requestable="true" data-aeon="false"' +
      '                data-holding-id="22614245530006421"><a title="View Options to Request copies from this Location"' +
      '                    class="request btn btn-xs btn-primary" data-toggle="tooltip"' +
      '                    href="/requests/99115992283506421?mfhd=22614245530006421&amp;source=pulsearch">Request</a></td>' +
      '            <td class="holding-details">' +
      '                <ul class="item-status" data-record-id="99115992283506421" data-holding-id="22614245530006421"></ul>' +
      '            </td>' +
      '        </tr>' +
      '        <tr class="holding-block">' +
      '            <td class="library-location" data-holding-id="22614245510006421"><span class="location-text"' +
      '                    data-location="true" data-holding-id="22614245510006421">Forrestal Annex - Reserve</span></td>' +
      '            <td class="holding-call-number">HB172.5 .B38 2020 <a class="browse-cn" title="Browse: HB172.5 .B38 2020"' +
      '                    data-toggle="tooltip" data-original-title="Browse: HB172.5 .B38 2020"' +
      '                    href="/browse/call_numbers?q=HB172.5+.B38+2020"><span class="link-text">Browse related items</span>' +
      '                    <span class="icon-bookslibrary"></span></a></td>' +
      '            <td class="holding-status" data-availability-record="true" data-record-id="99115992283506421"' +
      '                data-holding-id="22614245510006421" data-aeon="false"><span class="availability-icon"></span></td>' +
      '            <td class="location-services service-conditional" data-open="false" data-requestable="true"' +
      '                data-aeon="false" data-holding-id="22614245510006421"><a' +
      '                    title="View Options to Request copies from this Location" class="request btn btn-xs btn-primary"' +
      '                    data-toggle="tooltip"' +
      '                    href="/requests/99115992283506421?mfhd=22614245510006421&amp;source=pulsearch">Request</a></td>' +
      '            <td class="holding-details">' +
      '                <ul class="item-status" data-record-id="99115992283506421" data-holding-id="22614245510006421"></ul>' +
      '            </td>' +
      '        </tr>' +
      '    </tbody>' +
      '</table>';

    const holding_availability_info = {
      "on_reserve": "Y",
      "location": "annex$reserve",
      "label": "Forrestal Annex - Reserve",
      "status_label": "Available",
      "copy_number": null,
      "cdl": false,
      "temp_location": false,
      "id": "22614245510006421"
    }

    const request_button_selector = `.location-services[data-holding-id='22614245510006421'] a`

    expect($(request_button_selector).length).toEqual(1)

    let u = new updater
    u.id = '9965126093506421'
    u.update_request_button('22614245510006421', holding_availability_info)

    expect($(request_button_selector).length).toEqual(0)
  })
})

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
    expect(badgesAfter[0].textContent).toEqual('Check record for availability')
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

  test('record has temporary locations and complete data', () => {
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

    // in this case we expect to call update_single
    let u = new updater
    u.id = '9959958323506421'
    const spy = jest.spyOn(u, 'update_single')
    u.process_single(holding_records)
    expect(spy).toHaveBeenCalled()
    spy.mockRestore()
  })

  test('record has temporary locations and incomplete data', () => {
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

    // in this case we expect NOT to call update_single since we have incomplete data
    let u = new updater
    u.id = '9959958323506421'
    const spy = jest.spyOn(u, 'update_single')
    u.process_single(holding_records)
    expect(spy).not.toHaveBeenCalled()
    spy.mockRestore()
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

    expect(holding_badge.textContent).toContain('Check record for availability');
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
})

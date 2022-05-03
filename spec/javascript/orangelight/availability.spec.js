import updater from 'orangelight/availability'
import { promises as fs } from 'fs';
import * as orangelight_online_link from '../../../app/javascript/orangelight/insert_online_link'

describe('AvailabilityUpdater', function() {
  afterEach(jest.clearAllMocks);

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

  test('search results availability for records in temporary locations says View record for Full Availability', () => {
    document.body.innerHTML =
    '<li class="blacklight-holdings">'+
    '  <ul>'+
    '    <li data-availability-record="true" data-record-id="9972879153506421" data-holding-id="lewis$resterm" data-aeon="false" data-bound-with="false">'+
    '      <span class="availability-icon badge badge-secondary">Loading...</span>'+
    '      <div class="library-location" data-location="true" data-record-id="9972879153506421" data-holding-id="lewis$resterm">'+
    '        <span class="results_location">Lewis Library - Term Loan Reserves</span> » <span class="call-number">QP355.2 .P76 2013 <a title="Where to find it" class="find-it"'+
    '      data-map-location="lewis$resterm" data-blacklight-modal="trigger" aria-label="Where to find it"'+
    '      href="/catalog/9972879153506421/stackmap?loc=lewis$resterm&amp;cn=QP355.2%20.P76%202013"></a></span>'+
    '      </div>'+
    '    </li>'+
    '    <li data-availability-record="true" data-record-id="9972879153506421" data-holding-id="22732100160006421" data-aeon="false" data-bound-with="false">'+
    '      <span class="availability-icon badge badge-secondary">Loading...</span>'+
    '      <div class="library-location" data-location="true" data-record-id="9972879153506421" data-holding-id="22732100160006421">'+
    '        <span class="results_location">Engineering Library - Stacks</span> » <span class="call-number">QP355.2 .P76 2013 <a title="Where to find it" class="find-it"'+
    '        data-map-location="engineer$stacks" data-blacklight-modal="trigger" aria-label="Where to find it"'+
    '        href="/catalog/9972879153506421/stackmap?loc=engineer$stacks&amp;cn=QP355.2%20.P76%202013"></a></span>'+
    '      </div>'+
    '    </li>'+
    '    <li class="empty" data-record-id="9972879153506421">'+
    '      <a class="availability-icon more-info" title="Click on the record for full availability info" data-toggle="tooltip" href="/catalog/9972879153506421"></a>'+
    '    </li>'+
    '  </ul>'+
    '</li>'


    const apiResponse = {
      "9972879153506421": {
        "lewis$resterm": {
        "on_reserve": "N",
        "location": "lewis$resterm",
        "label": "Lewis Library - Term Loan Reserves",
        "status_label": "Available",
        "copy_number": null,
        "cdl": false,
        "temp_location": true,
        "id": "lewis$resterm"
        },
        "22732100160006421": {
        "on_reserve": "N",
        "location": "engineer$stacks",
        "label": "Engineering Library - Stacks",
        "status_label": "Available",
        "copy_number": null,
        "cdl": false,
        "temp_location": false,
        "id": "22732100160006421"
        }
      }
    }


    const badgesBefore = document.getElementsByClassName('availability-icon')
    expect(badgesBefore[0].textContent).toEqual('Loading...')

    const bibId = '9972879153506421'
    const holdingData = apiResponse[bibId]
    let u = new updater
    u.process_result(bibId, holdingData)

    const badgesAfter = document.getElementsByClassName('availability-icon')
    expect(badgesAfter[0].textContent).toEqual('View record for Full Availability')
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

  test('when a record has temporary and permanent locations we display the status for both', () => {
    document.body.innerHTML = '<table>'+
    '  <tbody>'+
    '    <tr class="holding-block">'+
    '      <td class="library-location" data-holding-id="22732100160006421">'+
    '        <span class="location-text" data-location="true" data-holding-id="22732100160006421">Engineering Library - Stacks</span> <a title="Where to find it" class="find-it"'+ 
    'data-map-location="engineer$stacks" data-blacklight-modal="trigger" data-call-number="QP355.2 .P76 2013" data-library="Engineering Library"'+ 
    'href="/catalog/9972879153506421/stackmap?loc=engineer$stacks&amp;cn=QP355.2%20.P76%202013"><span class="link-text">Where to find it</span> </a>'+
    '      </td>'+
    '      <td class="holding-call-number">'+
    '        QP355.2 .P76 2013 <a class="browse-cn" title="Browse: QP355.2 .P76 2013" data-toggle="tooltip" data-original-title="Browse: QP355.2 .P76 2013"'+ 
    'href="/browse/call_numbers?q=QP355.2+.P76+2013"><span class="link-text">Browse related items</span> </a>'+
    '      </td>'+
    '      <td class="holding-status" data-availability-record="true" data-record-id="9972879153506421" data-holding-id="22732100160006421" data-aeon="false">'+
    '        <span class="availability-icon" title=""></span>'+
    '      </td>'+
    '      <td class="location-services service-conditional" data-open="true" data-requestable="true" data-aeon="false" data-holding-id="22732100160006421">'+
    '        <a title="View Options to Request copies from this Location" class="request btn btn-xs btn-primary" data-toggle="tooltip"'+ 'href="/requests/9972879153506421?mfhd=22732100160006421">Request</a>'+
    '      </td>'+
    '      <td class="holding-details">'+
    '        <ul class="item-status" data-record-id="9972879153506421" data-holding-id="22732100160006421"></ul>'+
    '      </td>'+
    '    </tr>'+
    '    <tr class="holding-block">'+
    '      <td class="library-location" data-holding-id="lewis$resterm">'+
    '        <span class="location-text" data-location="true" data-holding-id="lewis$resterm">Lewis Library - Term Loan Reserves</span> <a title="Where to find it" class="find-it"'+ 
    'data-location-map="lewis$resterm" data-blacklight-modal="trigger" href="/catalog/9972879153506421/stackmap?loc=lewis$resterm"><span class="link-text">Where to find it</span></a>'+
    '      </td>'+
    '      <td class="holding-call-number">'+
    '        QP355.2 .P76 2013 <a class="browse-cn" title="Browse: QP355.2 .P76 2013" data-toggle="tooltip" data-original-title="Browse: QP355.2 .P76 2013"'+ 
    'href="/browse/call_numbers?q=QP355.2+.P76+2013"><span class="link-text">Browse related items</span> </a>'+
    '      </td>'+
    '      <td class="holding-status" data-availability-record="true" data-record-id="9972879153506421" data-holding-id="lewis$resterm" data-aeon="false">'+
    '        <span class="availability-icon" title=""></span>'+
    '      </td>'+
    '      <td class="location-services service-conditional" data-open="false" data-requestable="true" data-aeon="false" data-holding-id="lewis$resterm">'+
    '        <a title="" class="request btn btn-xs btn-primary" data-toggle="tooltip" href="/requests/9972879153506421?mfhd=22732100140006421" data-original-title="View Options to Request copies'+ 
    'from this Location">Request</a>'+
    '      </td>'+
    '      <td class="holding-details">'+
    '        <ul class="item-status" data-record-id="9972879153506421" data-holding-id="lewis$resterm"></ul>'+
    '      </td>'+
    '    </tr>'+
    '  </tbody>'+
    '</table>'

    const availability_response = {
      "9972879153506421": {
        "lewis$resterm": {
        "on_reserve": "N",
        "location": "lewis$resterm",
        "label": "Lewis Library - Term Loan Reserves",
        "status_label": "Available",
        "copy_number": null,
        "cdl": false,
        "temp_location": true,
        "id": "lewis$resterm"
        },
        "22732100160006421": {
        "on_reserve": "N",
        "location": "engineer$stacks",
        "label": "Engineering Library - Stacks",
        "status_label": "Available",
        "copy_number": null,
        "cdl": false,
        "temp_location": false,
        "id": "22732100160006421"
        }
      }
    }
    let u = new updater
    u.id = '9972879153506421'
    u.process_single(availability_response)

    const badge = document.getElementsByClassName('availability-icon')[0]
    expect(badge.classList.values()).toContain('badge')
    expect(badge.classList.values()).toContain('badge-success')
    expect(badge.textContent).toEqual('Available')

    const badge_second = document.getElementsByClassName('availability-icon')[1]
    expect(badge_second.classList.values()).toContain('badge')
    expect(badge_second.classList.values()).toContain('badge-success')
    expect(badge_second.textContent).toEqual('Available')
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
        '<td class="holding-status" data-availability-record="true" data-record-id="99124994093506421" data-holding-id="22488152160006421" data-aeon="false">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = {
      "9929455793506421":{},
      "99124994093506421":{"22488152160006421":{"on_reserve":"N","location":"recap$pa","label":"ReCAP - ReCAP - rcppa RECAP","status_label":"Available","copy_number":null,"cdl":false,"temp_location":false,"id":"22488152160006421"}}
    }

    let u = new updater
    u.id = '9929455793506421'         // constituent record
    u.host_id = ["99124994093506421"]  // host mms_id
    u.mms_id = u.host_id[0] // 

    const update_single = jest.spyOn(u, 'update_single')
    u.process_single(holding_records)

    expect(update_single).toHaveBeenCalledWith(holding_records, u.id)
    expect(update_single).toHaveBeenCalledWith(holding_records, u.mms_id)
    update_single.mockRestore()
  })


  test('record search results page for a bound-with record', () => {
    // Notice the data-bound-with="true"
    document.body.innerHTML =
      '<table><tr>' +
        '<td class="holding-status" data-availability-record="true" data-record-id="9929455793506421" data-holding-id="22488152160006421" data-aeon="false" data-bound-with="true">' +
          '<span class="availability-icon"></span>' +
        '</td>' +
      '</tr></table>';
    const holding_records = 
    {"22488152160006421": {
      "on_reserve": "N",
      "location": "recap$pa",
      "label": "ReCAP - Remote Storage",
      "status_label": "Available",
      "copy_number": null,
      "cdl": false,
      "temp_location": false,
      "id": "22488152160006421"
    }}
    const holding_badge = $("*[data-availability-record='true'][data-record-id='9929455793506421'][data-bound-with='true'] span.availability-icon")[0];

    let u = new updater
    u.process_result("9929455793506421", holding_records)

    expect(holding_badge.textContent).toContain('View record for Full Availability');
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

  test('in the Show page we display Online instead of Unavailable for CDL records', () => {
    document.body.innerHTML = '<table><tbody>' +
    '<tr class="holding-block">' +
    '  <td class="library-location" data-holding-id="22745424290006421">' +
    '    <span class="location-text" data-location="true" data-holding-id="22745424290006421">Firestone Library - Firestone Library</span>' +
    '    <a title="Where to find it" class="find-it" data-map-location="firestone$stacks" data-blacklight-modal="trigger"' +
    '      data-call-number="HB172 .G664 2016" data-library="Firestone Library"' +
    '      href="/catalog/9999490563506421/stackmap?loc=firestone$stacks&amp;cn=HB172 .G664 2016">' +
    '      <span class="link-text">Where to find it</span>' +
    '      <span class="fa fa-map-marker" aria-hidden="true"></span>' +
    '    </a>' +
    '  </td>' +
    '  <td class="holding-call-number">HB172 .G664 2016' +
    '    <a class="browse-cn" title="Browse: HB172 .G664 2016" data-toggle="tooltip"' +
    '      data-original-title="Browse: HB172 .G664 2016" href="/browse/call_numbers?q=HB172+.G664+2016">' +
    '      <span class="link-text">Browse related items</span>' +
    '      <span class="icon-bookslibrary"></span>' +
    '    </a>' +
    '  </td>' +
    '  <td class="holding-status" data-availability-record="true" data-record-id="9999490563506421"' +
    '    data-holding-id="22745424290006421" data-aeon="false">' +
    '    <span class="availability-icon badge " title=""></span>' +
    '  </td>' +
    '  <td class="location-services service-conditional" data-open="true" data-requestable="true" data-aeon="false"' +
    '    data-holding-id="22745424290006421"></td>' +
    '  <td class="holding-details">' +
    '    <ul class="item-status" data-record-id="9999490563506421" data-holding-id="22745424290006421"></ul>' +
    '  </td>' +
    '</tr>' +
    '</tbody></table>';

    const availability_response = {
      "9999490563506421": {
        "22745424290006421": {
          "on_reserve": "N",
          "location": "firestone$stacks",
          "label": "Firestone Library - Firestone Library",
          "status_label": "Unavailable",
          "copy_number": null,
          "cdl": true,
          "temp_location": false,
          "id": "22745424290006421"
        }
      }
    }

    const holding_data = availability_response["9999490563506421"]["22745424290006421"];

    const av_element = $(`*[data-availability-record='true'][data-record-id='9999490563506421'][data-holding-id='22745424290006421'] .availability-icon`);
    let u = new updater;
    u.id = '9999490563506421';

    expect(av_element[0].textContent).not.toContain('Online');
    u.apply_availability_label(av_element, holding_data, false);
    expect(av_element[0].textContent).toContain('Online');
  })

  test('special case for Marquand locations - marquand$stacks,marquand$pj,marquand$ref,marquand$ph,marquand$fesrf - items to display status: Ask Staff', () => {
    document.body.innerHTML = '<table class="availability-table">' +
      '<tbody>' +
      '  <tr class="holding-block">' +
      '    <td class="library-location" data-holding-id="22642015240006421">' +
      '      <span class="location-text" data-location="true" data-holding-id="22642015240006421">Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only</span>' +
      '    </td>' +
      '    <td class="holding-call-number"></td>' +
      '    <td class="holding-status" data-availability-record="true" data-record-id="99124187703506421" data-holding-id="22642015240006421" data-aeon="false">'  +
      '      <span class="availability-icon badge badge-secondary" title=""></span>' +
      '    </td>' +
      '    <td class="location-services service-conditional" data-open="false" data-requestable="true" data-aeon="false" data-holding-id="22642015240006421">' +
      '     <a title="View Options to Request copies from this Location" class="request btn btn-xs btn-primary" data-toggle="tooltip" href="/requests/99124187703506421?mfhd=22642015240006421">Request</a>' +
      '    </td>' +
      '    <td class="holding-details">' +
      '      <ul class="item-status" data-record-id="99124187703506421" data-holding-id="22642015240006421"></ul>' +
      '    </td>' +
      '  </tr>' +
      '</tbody>' +
      '</table>';

    const availability_response = {
      "99124187703506421": {
        "22642015240006421": {
        "on_reserve": "N",
        "location": "marquand$pj",
        "label": "Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only",
        "status_label": "Unavailable",
        "copy_number": null,
        "cdl": false,
        "temp_location": false,
        "id": "22642015240006421"
        }
      }
    }
    const holding_data = availability_response["99124187703506421"]["22642015240006421"];
    const av_element = $(`*[data-availability-record='true'][data-record-id='99124187703506421'][data-holding-id='22642015240006421'] .availability-icon`);

    let u = new updater;
    u.id = '99124187703506421';

    expect(av_element[0].textContent).not.toContain('Ask Staff');
    u.apply_availability_label(av_element, holding_data, false);
    expect(av_element[0].textContent).toContain('Ask Staff');
  })

  test('location RES_SHARE$IN_RS_REQ has status Unavailable', () => {
    document.body.innerHTML =
    '<table><tr>' +
    '<td class="holding-status" data-availability-record="true" data-record-id="99118399983506421" data-holding-id="RES_SHARE$IN_RS_REQ" data-aeon="false">' +
    '  <span class="availability-icon" title="">Available</span>' +
    '</td>'
    '<tr><table>';
    const res_share_response = {
        "99118399983506421": {
        "RES_SHARE$IN_RS_REQ": {
        "on_reserve": "N",
        "location": "RES_SHARE$IN_RS_REQ",
        "label": "Resource Sharing Library - Lending Resource Sharing Requests",
        "status_label": "Unavailable",
        "copy_number": null,
        "cdl": false,
        "temp_location": true,
        "id": "RES_SHARE$IN_RS_REQ"
        }
        }
    }
    let u = new updater;
    u.id = '99118399983506421';
    const element = $(`*[data-availability-record='true'][data-record-id='99118399983506421'][data-holding-id='RES_SHARE$IN_RS_REQ'] .availability-icon`);
    const holding_data = res_share_response["99118399983506421"]["RES_SHARE$IN_RS_REQ"]
    expect(element[0].textContent).not.toContain('Unavailable');
    u.apply_availability_label(element, holding_data, false);
    expect(element[0].textContent).toContain('Unavailable');
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
})

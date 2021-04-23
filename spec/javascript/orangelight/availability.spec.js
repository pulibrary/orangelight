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

import updater from 'orangelight/availability'
import { insert_online_link, insert_online_header } from 'orangelight/insert_online_link'

describe('AvailabilityUpdater', function() {
  test('hooked up right', () => {
    expect(updater).not.toBe(undefined)
  })

  test('insert_online_header() when there was no header', () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--physical"></div></div>'
    insert_online_header()

    const onlineDiv = document.getElementsByClassName('availability--online:visible')
    expect(onlineDiv.length).toEqual(1)
  })

  test("insert_online_header() doesn't add a new one when there was already a header", () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online:visible"></div><div class="availability--physical"></div></div>'
    insert_online_header()

    const onlineDiv = document.getElementsByClassName('availability--online:visible')
    expect(onlineDiv.length).toEqual(1)
  })

  test("insert_online_link() adds a new link to the list", () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online:visible"><ul></ul></div><div class="availability--physical"></div></div>'
    let u = new updater
    insert_online_link()

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(1)
    let list_item = li_elements.item(0)
    expect(list_item.textContent).toEqual("Princeton users: View digital content")
    const anchor = list_item.getElementsByTagName('a').item(0)
    expect(anchor.getAttribute("href")).toEqual("#view")
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

  test('record_ids() on a show page', () => {
    document.body.innerHTML =
      '<div>' +
      '<li data-availability-record="true" data-record-id="8938641" data-holding-id="8856502" data-aeon="false">' +
      '  <span class="availability-icon badge badge-primary" title="" data-toggle="tooltip" data-original-title="Electronic access">Online</span>' +
      '</li>' +
      '</div>'
    let u = new updater
    expect(u.record_ids()).toEqual(['8938641'])
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

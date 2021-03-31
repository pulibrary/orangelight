import HathiConnector from 'orangelight/hathi_connector'
import updater from 'orangelight/voyager_availability'

jest.mock('orangelight/hathi_connector')

beforeEach(() => {
  // Clear all instances and calls to constructor and all methods:
  HathiConnector.mockClear();
});

describe('VoyagerAvailabilityUpdater', function() {
  test('hooked up right', () => {
    expect(updater).not.toBe(undefined)
  })

  test('process_single when the record has a temporary etas location shows a link', () => {

    document.body.innerHTML =
      '<td class="holding-status" data-availability-record="true" data-record-id="999998" data-holding-id="1153009" data-aeon="false"><span class="availability-icon"></span></td>'
    const holding_records = {"1153009":{"more_items":false,"location":"rcppa","temp_loc":"etas","course_reserves":[],"copy_number":1,"item_id":1244099,"on_reserve":"N","patron_group_charged":null,"status":"On-Site","label":"Online - HathiTrust Emergency Temporary Access"}}
    let u = new updater
    u.process_single(holding_records)
    expect(HathiConnector).toHaveBeenCalled()
})

  test('process_single when the record has a temporary etas location and is on hold does not show a link', () => {

    document.body.innerHTML =
      '<td class="holding-status" data-availability-record="true" data-record-id="999998" data-holding-id="1153009" data-aeon="false"><span class="availability-icon"></span></td>'
    const holding_records = {"1153009":{"more_items":false,"location":"rcppa","temp_loc":"etas","course_reserves":[],"copy_number":1,"item_id":1244099,"on_reserve":"N","patron_group_charged":null,"status":"On Hold","label":"Online - HathiTrust Emergency Temporary Access"}}
    let u = new updater
    u.process_single(holding_records)
    expect(HathiConnector).not.toHaveBeenCalled()
})

  test('process_single when the record has a temporary etas location and is checked out does not show a link', () => {

    document.body.innerHTML =
      '<td class="holding-status" data-availability-record="true" data-record-id="999998" data-holding-id="1153009" data-aeon="false"><span class="availability-icon"></span></td>'
    const holding_records = {"1153009":{"more_items":false,"location":"rcppa","temp_loc":"etas","course_reserves":[],"copy_number":1,"item_id":1244099,"on_reserve":"N","patron_group_charged":null,"status":"Charged","label":"Online - HathiTrust Emergency Temporary Access"}}
    let u = new updater
    u.process_single(holding_records)
    expect(HathiConnector).not.toHaveBeenCalled()
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

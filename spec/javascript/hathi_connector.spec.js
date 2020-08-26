import hathi_connector from 'orangelight/hathi_connector'
import { promises as fs } from 'fs';

describe('HathiConnector', function() {
  test('hooked up right', () => {
    expect(hathi_connector).not.toBe(undefined)
  })

  test('process_hathi_data()', async () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online:visible"><ul></ul></div><div class="availability--physical"></div></div>'
    const expectedUrl =
        'https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=' +
      'https://idp.princeton.edu/idp/shibboleth&target=' +
      'https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Dmdp.39015047450062'
    let json_response = await fs.readFile("spec/fixtures/hathi_42579288.json", 'utf8')
    json_response = JSON.parse(json_response)

    const connector = new hathi_connector
    connector.process_hathi_data(json_response)

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(1)
    const list_item = li_elements.item(0)
    expect(list_item.textContent).toEqual("Princeton users: View digital content")
    const anchor = list_item.getElementsByTagName('a').item(0)
    expect(anchor.getAttribute("href")).toEqual(expectedUrl)
  })

  test('oclc_number()', () => {
    document.body.innerHTML =
      '<div><meta property="http://purl.org/library/oclcnum" content="42579288"></div>'
    const connector = new hathi_connector
    expect(connector.oclc_number()).toEqual("42579288")
  })
})

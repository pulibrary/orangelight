import hathi_connector from 'orangelight/hathi_connector'
import { promises as fs } from 'fs';

describe('HathiConnector', function() {
  test('hooked up right', () => {
    expect(hathi_connector).not.toBe(undefined)
  })

  test('oclc_number()', () => {
    document.body.innerHTML =
      '<div><meta property="http://purl.org/library/oclcnum" content="42579288"></div>'
    const connector = new hathi_connector
    expect(connector.oclc_number()).toEqual("42579288")
  })

  test('get_hathi_id()', async () => {
    const oclc_number = "42579288"
    const connector = new hathi_connector
    const id = await connector.get_hathi_id(oclc_number)
    expect(id).toEqual("mdp.39015047450062")
  })

  test('insert_hathi_link()', async () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online:visible"><ul></ul></div><div class="availability--physical"></div></div>'
    let json_response = await fs.readFile("spec/fixtures/hathi_42579288.json", 'utf8')
    json_response = JSON.parse(json_response)

    const connector = new hathi_connector
    connector.insert_hathi_link(json_response)

    const link = document.getElementsByTagName('li')
    expect(link.length).toEqual(1)
    const link_item = link.item(0)
    expect(link_item.textContent).toEqual("Princeton users: View digital content")
    const hathi_link = link_item.getElementsByTagName('a').item(0)
    expect(hathi_link.getAttribute("href")).toEqual("https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Dmdp.39015047450062")
  })

  test('get_url()', () => {
    document.body.innerHTML =
      '<meta property="http://purl.org/library/oclcnum" content="42579288">'
    const expectedUrl =
        'https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=' +
      'https://idp.princeton.edu/idp/shibboleth&target=' +
      'https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Dmdp.39015047450062'
    // TODO: stub hathi api response
    //stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/42579288.json")
    //  .to_return(body: File.new('spec/fixtures/hathi_42579288.json'), status: 200)
    const connector = new hathi_connector
    expect(connector.get_url()).toEqual(expectedUrl)
  })
})

import hathi_connector from 'orangelight/hathi_connector'

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

  test('get_hathi_id()', () => {
    const oclc_number = "42579288"
    const connector = new hathi_connector
    expect(connector.get_hathi_id(oclc_number)).toEqual("mdp.39015047450062")
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

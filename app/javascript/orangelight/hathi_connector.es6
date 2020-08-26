import { insert_online_link } from 'orangelight/insert_online_link'

export default class HathiConnector {
  async insert_hathi_link(oclc_number) {
    // The API also offers isbn or lccn but we're just using oclc number
    const url = `https://catalog.hathitrust.org/api/volumes/brief/oclc/${this.oclc_number()}.json?callback=?`
    return $.getJSON(url).promise()
      .then(this.process_hathi_data)
  }

  process_hathi_data(hathiData) {
    const base_url = "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3D"
    let mdp_id = hathiData.items[0].htid
    let url = base_url + mdp_id
    insert_online_link(url)
  }

  oclc_number() {
    return document.querySelector("meta[property='http://purl.org/library/oclcnum']").content
  }
}

import { insert_online_link } from 'orangelight/insert_online_link'
export default class HathiConnector {
  constructor() {
    this.base_url = "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3D"
  }

  get_url() {
    return this.base_url + this.get_hathi_id(this.oclc_number())
  }

  async get_hathi_id(oclc_number) {
    // The API also offers isbn or lccn but we're just using oclc number
    const url = `https://catalog.hathitrust.org/api/volumes/brief/oclc/${oclc_number}.json?callback=?`
    //fetch(url).then(response => response.json()).then(data => data)
    return $.getJSON(url).promise().then((data) => console.log(data))
  }

  insert_hathi_link(hathiData) {
    let mdp_id = hathiData.items[0].htid
    let url = this.base_url + mdp_id
    insert_online_link(url)
  }

  oclc_number() {
    return document.querySelector("meta[property='http://purl.org/library/oclcnum']").content
  }
}

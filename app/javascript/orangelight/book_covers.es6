export default class BookCoverManager {

  constructor() {
    this.google_url = "https://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=";
    this.identifiers = {
      isbn: "isbn",
      oclc: "http://purl.org/library/oclcnum"
    };
    this.find_book_covers();
  }

  find_book_covers() {
    return this.get_number();
  }

  get_number() {
    var all_identifiers = [];
    Object.entries(this.identifiers).forEach(([identifier_type, field]) => {
      var ids = this.find_identifiers(identifier_type, field);
      if (ids) {
        ids.forEach((id) => {
          all_identifiers.push(id);
        });
      }
    });
    this.fetch_identifiers(all_identifiers);
    return true;
  }

  fetch_identifiers(ids) {
    const url = `${this.google_url}${ids.join(',')}`;
    $.getJSON(url).done(this.process_results);
  }

  process_results(data) {
    Object.entries(data).forEach(([id, info]) => {
      if (info.thumbnail_url) {
        const identifier_type = id.split(":")[0];
        const id_value = id.split(":")[1];
        const type_matches = $(`*[data-${identifier_type}]`);
        const thumbnail_element = type_matches.filter((i, element) => {
          return $(element).data(identifier_type).indexOf(id_value) != -1
        })[0];
        const thumbnail_url = info.thumbnail_url
          .replace(/zoom=./,"zoom=1")
          .replace("&edge=curl","");
        const new_thumbnail = $(`<img alt='' src='${thumbnail_url}'>`);
        $(thumbnail_element).html('');
        $(thumbnail_element).append(new_thumbnail);
      }
    });
  }

  find_identifiers(identifier_type, property) {
    const id = $(`meta[property='${property}']`);
    const ids = id.map((i, x) => `${$(x).prop('content').replace(/[^0-9]/g, '')}`)
      .toArray();
    if (ids === []) {
      return null;
    } else {
      return ids.map((x) => `${identifier_type}:${x}`);
    }
  }
}

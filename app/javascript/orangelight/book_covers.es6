import { cleanJson } from './clean_json.es6';

export default class BookCoverManager {
  constructor() {
    this.google_url =
      'https://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=';
    this.identifiers = {
      isbn: 'isbn',
      oclc: 'http://purl.org/library/oclcnum',
    };
  }

  async addCoverImages() {
    var all_identifiers = [];
    Object.entries(this.identifiers).forEach(([identifier_type, field]) => {
      var ids = this.find_identifiers(identifier_type, field);
      if (ids) {
        ids.forEach((id) => {
          all_identifiers.push(id);
        });
      }
    });
    await this.fetch_identifiers(all_identifiers);
    return true;
  }

  async fetch_identifiers(ids) {
    const url = `${this.google_url}${ids.join(',')}`;
    const response = await fetch(url);
    const body = await response.text();
    this.process_results(cleanJson(body));
  }

  process_results(data) {
    Object.entries(data).forEach(([id, info]) => {
      if (info.thumbnail_url) {
        const identifier_type = id.split(':')[0];
        const id_value = id.split(':')[1];
        const type_matches = $(`*[data-${identifier_type}]`);
        const thumbnail_element = type_matches.filter((i, element) => {
          return $(element).data(identifier_type).indexOf(id_value) != -1;
        })[0];
        const thumbnail_url = info.thumbnail_url
          .replace(/zoom=./, 'zoom=1')
          .replace('&edge=curl', '');
        const new_thumbnail = $(`<img alt='' src='${thumbnail_url}'>`);
        $(thumbnail_element).html('');
        $(thumbnail_element).append(new_thumbnail);
      }
    });
  }

  find_identifiers(identifier_type, property) {
    const id = $(`meta[property='${property}']`);
    const ids = id
      .map(
        (i, x) =>
          `${$(x)
            .prop('content')
            .replace(/[^0-9]/g, '')}`
      )
      .toArray();
    return ids.map((x) => `${identifier_type}:${x}`);
  }
}

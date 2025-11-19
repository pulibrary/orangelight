import { requestJsonP } from './json_p.es6';

// This function has to be part of the global window object, because
// it is the callback for a JsonP request
window.addBookCoversToDom = (data) => {
  Object.entries(data).forEach(([id, info]) => {
    if (info.thumbnail_url) {
      const [identifierType, idValue] = id.split(':');
      const elementsWithIdentifierType = document.querySelectorAll(
        `*[data-${identifierType}]`
      );
      const thumbnailElement = Array.from(elementsWithIdentifierType).find(
        (element) => element.dataset[identifierType].indexOf(idValue) != -1
      );
      const thumbnailUrl = info.thumbnail_url
        .replace(/zoom=./, 'zoom=1')
        .replace('&edge=curl', '');
      const newThumbnail = document.createElement('img');
      newThumbnail.setAttribute('alt', '');
      newThumbnail.setAttribute('src', thumbnailUrl);
      thumbnailElement.childNodes.forEach((element) => element.remove());
      thumbnailElement.appendChild(newThumbnail);
    }
  });
};

export default class BookCoverManager {
  constructor(requestFn = null) {
    this.google_url =
      'https://books.google.com/books?callback=addBookCoversToDom&jscmd=viewapi&bibkeys=';
    this.identifiers = {
      isbn: 'isbn',
      oclc: 'http://purl.org/library/oclcnum',
    };
    this.requestFn = requestFn || requestJsonP;
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
    this.requestFn(url);
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

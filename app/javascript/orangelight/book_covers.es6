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
    this.#sendBookCoversRequest();
  }

  #sendBookCoversRequest() {
    const allIdentifiers = Object.entries(this.identifiers).reduce(
      (accumulator, identiferData) => {
        const [identifierType, property] = identiferData;
        return accumulator.concat(
          this.#identifiersFromDom(identifierType, property)
        );
      },
      []
    );
    this.#request(allIdentifiers);
    return true;
  }

  #request(ids) {
    const url = `${this.google_url}${ids.join(',')}`;
    this.requestFn(url);
  }

  // Get identifiers that we can send to Google Books
  // The identifiers are in these formats:
  // <meta property="isbn" itemprop="isbn" content="9782490952229">
  // <meta property="http://purl.org/library/oclcnum" content="1299297250">
  // We want them to be in the formats:
  // isbn:9782490952229 and oclc:1299297250
  #identifiersFromDom(identifierType, property) {
    const identifierElements = document.querySelectorAll(
      `meta[property='${property}']`
    );
    return Array.from(identifierElements).map(
      (element) =>
        `${identifierType}:${element.getAttribute('content').replace(/[^0-9]/g, '')}`
    );
  }
}

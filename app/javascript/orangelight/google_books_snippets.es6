import { insert_online_link } from './insert_online_link.es6';

export default class GoogleBooksSnippets {
  get has_figgy_viewer() {
    return !!document.querySelector('.document-viewers > .intrinsic-container');
  }

  get isbn() {
    return [...document.querySelectorAll("meta[property='isbn']")].map((meta) =>
      meta.getAttribute('content')
    );
  }

  get isJournal() {
    return (
      document.querySelector('dd.blacklight-format')?.textContent?.trim() ===
      'Journal'
    );
  }

  get onlineOnly() {
    const locationData = JSON.parse(
      document.querySelector('#document')?.dataset['location'] || '[]'
    );
    const onlineCodes = ['elf1', 'elf2', 'elf4', 'Online'];
    const diff = locationData.filter((x) => onlineCodes.includes(x));
    if (diff.length > 0) return true;
    return false;
  }

  get googleUrl() {
    return `https://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=${this.isbn.join(',')}`;
  }

  async insert_snippet() {
    if (this.isJournal || this.onlineOnly) return;
    // Make a JSON-P request to this API: https://developers.google.com/books/docs/dynamic-links
    return $.getJSON(this.googleUrl)
      .promise()
      .then(this.process_google_response.bind(this));
  }

  process_google_response(response) {
    for (const key in response) {
      const result = response[key];
      if (result.preview === 'partial' || result.preview === 'full') {
        const previewString =
          result.preview.charAt(0).toUpperCase() + result.preview.slice(1);
        const url = new URL(result.preview_url);
        const bookId = url.searchParams.get('id');
        const link = `https://www.google.com/books/edition/_/${bookId}?hl=en&gbpv=1&pg=PP1`;
        const content = (link, target) => {
          return `<a href="${link}" target="${target}">Google Books (${previewString} View)<lux-icon-base width='18' height='18' icon-name='Add Item'><lux-icon-new-tab class='lux-icon lux-icon-new-tab new-tab-icon-padding' aria-label='opens in new tab' aria-hidden='true' role='img'></lux-icon-new-tab></lux-icon-base></a>`;
        };
        insert_online_link(link, 'google_preview_link', content);
        break;
      }
    }
  }
}

import { describe, vi } from 'vitest';
import BookCoverManager from '../../app/javascript/orangelight/book_covers.es6';

describe('BookCoverManager', () => {
  it('can request ISBNs', async () => {
    fetch = vi.fn(() =>
      Promise.resolve(
        new Response(
          'var _GBSBookInfo = {"isbn:9789592750111":{"bib_key":"isbn:9789592750111","thumbnail_url":"https://books.google.com/books/content?id=I9gLAQAAMAAJ\u0026printsec=frontcover\u0026img=1\u0026zoom=5"}};'
        )
      )
    );
    document.body.innerHTML = `<span vocab="http://id.loc.gov/vocabulary/identifiers/">
    <meta property="isbn" itemprop="isbn" content="9789592750111">
</span>
<div class="document-thumbnail" data-isbn="[&quot;9789592750111&quot;]"><div class="default"></div></div>`;

    await new BookCoverManager().addCoverImages();
    const image = document.querySelector('img');
    expect(image.getAttribute('src')).toEqual(
      'https://books.google.com/books/content?id=I9gLAQAAMAAJ&printsec=frontcover&img=1&zoom=1'
    );
  });

  it('can request OCLC numbers', async () => {
    fetch = vi.fn(() =>
      Promise.resolve(
        new Response(
          'var _GBSBookInfo = {"oclc:1328062335":{"bib_key":"oclc:1328062335","thumbnail_url":"https://books.google.com/books/content?id=I9gLAQAAMAAJ\u0026printsec=frontcover\u0026img=1\u0026zoom=5"}};'
        )
      )
    );
    document.body.innerHTML = `<span vocab="http://id.loc.gov/vocabulary/identifiers/">
    <meta property="http://purl.org/library/oclcnum" content="1328062335">
</span>
<div class="document-thumbnail" data-oclc="[&quot;1328062335&quot;]"><div class="default"></div></div>`;
    await new BookCoverManager().addCoverImages();
    const image = document.querySelector('img');
    expect(image.getAttribute('src')).toEqual(
      'https://books.google.com/books/content?id=I9gLAQAAMAAJ&printsec=frontcover&img=1&zoom=1'
    );
  });
});

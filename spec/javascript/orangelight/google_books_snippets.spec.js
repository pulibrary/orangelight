import GoogleBooksSnippets from 'orangelight/google_books_snippets'
import { promises as fs } from 'fs';

describe('GoogleBooksSnippets', function () {
  beforeEach(() => {
    window.google = { books: { load: function() {}, setOnLoadCallback: function(fn) { fn() }} }
  })
  test('hooked up right', () => {
    expect(GoogleBooksSnippets).not.toBe(undefined)
  })

  test("has_figgy_viewer returns true when there's a figgy viewer", () => {
    document.body.innerHTML = "<div class='document-viewers'><div class='intrinsic-container intrinsic-container-16x9'></div></div>"
    const google_books_snippets = new GoogleBooksSnippets
    expect(google_books_snippets.has_figgy_viewer).toBe(true)
  })

  test("has_figgy_viewer returns false when there's no figgy viewer", () => {
    document.body.innerHTML = "<div class='document-viewers'></div>"
    const google_books_snippets = new GoogleBooksSnippets
    expect(google_books_snippets.has_figgy_viewer).toBe(false)
  })

  test("isbn returns the meta isbn value", () => {
    document.body.innerHTML = '<meta property="isbn" itemprop="isbn" content="9780618643103">'
    const google_books_snippets = new GoogleBooksSnippets
    expect(google_books_snippets.isbn).toEqual(["9780618643103"])
  })

  test("isJournal returns true if format is set", () => {
    // Weird spacing is true in prod, so make sure it's tested.
    document.body.innerHTML = '<dd class="blacklight-format" dir="ltr">Journal' +
                              '                 </dd>'
    const google_books_snippets = new GoogleBooksSnippets
    expect(google_books_snippets.isJournal).toEqual(true)
    document.body.innerHTML = '<dd class="blacklight-format" dir="ltr">Other</dd>'
    expect(google_books_snippets.isJournal).toEqual(false)
  })

  test('insert_snippet does nothing if a journal', async () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online"><ul></ul></div><div class="availability--physical"></div></div>' +
      '<meta property="isbn" itemprop="isbn" content="9780618643103">' +
      '<meta property="isbn" itemprop="isbn" content="9781911300069">' +
      '<dd class="blacklight-format" dir="ltr">Journal</dd>'
    const google_books_snippets = new GoogleBooksSnippets

    await google_books_snippets.insert_snippet()

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(0)
  })

  test('insert_snippet adds the google book link to available content', async () => {
    document.body.innerHTML =
      '<div class="wrapper"><div class="availability--online"><ul></ul></div><div class="availability--physical"></div></div>' +
      '<meta property="isbn" itemprop="isbn" content="9780618643103">' +
      '<meta property="isbn" itemprop="isbn" content="9781911300069">'
    const google_books_snippets = new GoogleBooksSnippets
    let json_response = await fs.readFile("spec/fixtures/google_book_search.json", 'utf8')
    json_response = JSON.parse(json_response)
    $.getJSON = jest.fn().mockImplementation(() => { return { 'promise': () => Promise.resolve(json_response)} })
    const expectedUrl = "https://www.google.com/books/edition/_/5FTiCgAAQBAJ?hl=en&gbpv=1&pg=PP1"

    await google_books_snippets.insert_snippet()

    const li_elements = document.getElementsByTagName('li')
    expect(li_elements.length).toEqual(1)
    const list_item = li_elements.item(0)
    expect(list_item.textContent.startsWith("Google Preview")).toEqual(true)
    const anchor = list_item.getElementsByTagName('a').item(0)
    expect(anchor.getAttribute("href")).toEqual(expectedUrl)
    expect(anchor.getAttribute("target")).toEqual("_blank")
  })
})

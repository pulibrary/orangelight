import GoogleBooksSnippets from 'orangelight/google_books_snippets'

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
    expect(google_books_snippets.isbn).toBe("9780618643103")
  })

  test('insert_snippet adds the google books snippet inside the document-viewers container', () => {
    document.body.innerHTML =
      '<meta property="isbn" itemprop="isbn" content="9780618643103">' +
      '<div class="document-viewers"></div>'
    const google_books_snippets = new GoogleBooksSnippets
    const load = jest.fn()
    window.google.books.DefaultViewer = jest.fn().mockImplementation(() => { return { load }})

    google_books_snippets.insert_snippet()
    const element = document.getElementById("google-book-wizard")
    expect(element).not.toBe(null)
    expect(load).toHaveBeenCalledWith("ISBN:9780618643103", google_books_snippets.not_found)

    const header = document.getElementById("google-books-header")
    expect(header.textContent).toBe("Digital Preview")
  })
})

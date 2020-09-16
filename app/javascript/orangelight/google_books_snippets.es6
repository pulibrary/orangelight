import { insert_online_link } from 'orangelight/insert_online_link'

export default class GoogleBooksSnippets {
  get has_figgy_viewer() {
      return $(".document-viewers > .intrinsic-container").length > 0
  }

  get isbn() {
    return $("meta[property='isbn']").map(function(){ return $(this).attr("content")}).toArray()
  }

  get isJournal() {
    return $("dd.blacklight-format").text().trim() === "Journal"
  }

  get googleUrl() {
    return `https://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=://books.google.com/books?callback=?&jscmd=viewapi&bibkeys=${this.isbn.join(",")}`
  }

  async insert_snippet() {
    if (this.isJournal) return
    return $.getJSON(this.googleUrl).promise()
      .then(this.process_google_response.bind(this))
  }

  get contentStatement() {
    return "Google Books contains a limited preview of this book, which may be in copyright and may not be available in electronic form through other services offered by Princeton University Library (PUL). We are sharing this link with an intent to make access to information as efficient as possible while physical access to our collections is limited. This item may still be requested for pickup or electronic fulfillment via the library catalog. PUL’S TEMPORARY USE OF THIS SERVICE SHOULD NOT BE INTERPRETED AS A RECOMMENDATION OR ENDORSEMENT OF ANY PRODUCTS OR SERVICES, INCLUDING ANY PRODUCTS OR SERVICES PRESENTED IN THIRD-PARTY ADVERTISEMENTS ON THIS SITE."

  }

  process_google_response(response) {
    for(const key in response) {
      const result = response[key]
      if(result.preview === "partial" || result.preview === "full")
      {
        const url = new URL(result.preview_url)
        const bookId = url.searchParams.get("id")
        const link = `https://www.google.com/books/edition/_/${bookId}?hl=en&gbpv=1&pg=PP1`
        const content = (link, target) => {
          return `<a href="${link}" target="${target}">Google Preview</a><p>${this.contentStatement}</p>`
        }
        insert_online_link(link, "google_preview_link", content)
        break
      }
    }
  }
}

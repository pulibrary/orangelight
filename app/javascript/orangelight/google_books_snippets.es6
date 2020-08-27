export default class GoogleBooksSnippets {
  constructor() {
    google.books.load()
  }

  get has_figgy_viewer() {
    return $(".document-viewers > .intrinsic-container").length > 0
  }

  get isbn() {
    return document.querySelector("meta[property='isbn']").content
  }

  insert_snippet() {
    google.books.setOnLoadCallback(() => {
      $(".document-viewers").append("<div id='google-book-wizard'></div>")
      const viewer = new google.books.DefaultViewer(document.getElementById("google-book-wizard"))
      viewer.load(`ISBN:${this.isbn}`, this.not_found);
    })
  }

  not_found() {
    $("#google-book-wizard").remove()
  }
}

export default class GoogleBooksSnippets {
  get has_figgy_viewer() {
    return $(".document-viewers > .intrinsic-container").length > 0
  }

  get isbn() {
    return document.querySelector("meta[property='isbn']").content
  }

  insert_snippet() {
    google.books.load()
    google.books.setOnLoadCallback(() => {
      $(".document-viewers").append("<div id='google-books-wrapper'><div id='google-books-header'><h2>Digital Preview</h2></div><div class='intrinsic-container intrinsic-container-google-books'><div id='google-book-wizard'></div></div></div>")
      const viewer = new google.books.DefaultViewer(document.getElementById("google-book-wizard"))
      viewer.load(`ISBN:${this.isbn}`, this.not_found);
    })
  }

  not_found() {
    $("#google-book-wizard").remove()
  }
}

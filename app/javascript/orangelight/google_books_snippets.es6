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
      $(".document-viewers").append("<div class='intrinsic-container intrinsic-container-google-books'><div id='google-book-wizard'></div></div>")
      const viewer = new google.books.DefaultViewer(document.getElementById("google-book-wizard"))
      viewer.load(`ISBN:${this.isbn}`, this.not_found);
    })
  }

  not_found() {
    $("#google-book-wizard").remove()
  }
}

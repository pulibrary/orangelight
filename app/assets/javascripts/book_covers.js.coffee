jQuery ->
  window.book_cover_manager = new BookCoverManager
class BookCoverManager
  google_url: "https://www.googleapis.com/books/v1/volumes?q="
  identifiers: {
    isbn: "isbn",
    oclc: "http://purl.org/library/oclcnum",
    lccn: "lccn"
  }
  constructor: ->
    this.find_book_covers()
  find_book_covers: ->
    number = this.get_number()
  requests: []
  get_number: ->
    identifier = null
    for identifier_type, field of @identifiers
      identifiers = this.find_identifier(identifier_type, field)
      if identifiers?
        for identifier in identifiers
          this.fetch_identifier(identifier)
    true
  fetch_identifier: (identifier) ->
    url = "#{@google_url}#{identifier}"
    @requests.push($.getJSON(url, this.process_record))
  find_identifier: (identifier_type, property) ->
    identifier = $("meta[property='#{property}']")
    identifier = identifier
      .map((_,x) -> "#{$(x).prop('content').replace(/[^0-9]/g, '')}")
      .toArray()
    if identifier == []
      null
    else
      identifier.map((x) -> "#{identifier_type}:#{x}")
  process_record: (data) =>
    return if data.totalItems == 0
    item = data.items[0].volumeInfo
    thumbnail = item.imageLinks?.thumbnail
    if thumbnail?
      for request in @requests
        request.abort()
      img = $("<img src='#{thumbnail}'/>")
      current_thumbnail = $(".document-thumbnail.blacklight-book .default")
      parent = current_thumbnail.parent()
      current_thumbnail.remove()
      parent.append(img)

jQuery ->
  window.book_cover_manager = new BookCoverManager
class BookCoverManager
  google_url: "https://books.google.com/books?callback=?&jscmd=viewapi&bibkeys="
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
    all_identifiers = []
    for identifier_type, field of @identifiers
      identifiers = this.find_identifier(identifier_type, field)
      if identifiers?
        for identifier in identifiers
          all_identifiers.push(identifier)
    this.fetch_identifiers(all_identifiers)
    true
  fetch_identifiers: (identifiers) ->
    url = "#{@google_url}#{identifiers.join(",")}"
    $.getJSON(url).done(this.process_results)
  process_results: (data) ->
    for identifier, info of data
      if info.thumbnail_url?
        identifier_type = identifier.split(":")[0]
        identifier = identifier.split(":")[1]
        type_matches = $("*[data-#{identifier_type}]")
        thumbnail_element = type_matches.filter( -> $(this).data(identifier_type).indexOf(identifier) != -1)[0]
        thumbnail_url = info.thumbnail_url.replace(/zoom=./,"zoom=1").replace("&edge=curl","")
        console.log(thumbnail_url)
        new_thumbnail = $("<img src='#{thumbnail_url}'>")
        $(thumbnail_element).html('')
        $(thumbnail_element).append(new_thumbnail)
  find_identifier: (identifier_type, property) ->
    identifier = $("meta[property='#{property}']")
    identifier = identifier
      .map((_,x) -> "#{$(x).prop('content').replace(/[^0-9]/g, '')}")
      .toArray()
    if identifier == []
      null
    else
      identifier.map((x) -> "#{identifier_type}:#{x}")
